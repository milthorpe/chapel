#!/usr/bin/env python3
#
# Copyright 2024-2024 Hewlett Packard Enterprise Development LP
# Other additional copyright holders may be indicated within.
#
# The entirety of this work is licensed under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
#
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from typing import (
    Any,
    Callable,
    Dict,
    Generic,
    Iterable,
    List,
    Optional,
    Set,
    Tuple,
    TypeVar,
    Union,
)
from collections import defaultdict
from dataclasses import dataclass, field
from bisect_compat import bisect_left, bisect_right
from symbol_signature import get_symbol_signature
import itertools
import os
import json
import re


import chapel
from chapel.lsp import location_to_range, error_to_diagnostic
from chapel.visitor import visitor, enter
from pygls.server import LanguageServer
from pygls.workspace import TextDocument
from lsprotocol.types import (
    Location,
    MessageType,
    Diagnostic,
    Range,
    Position,
)
from lsprotocol.types import TEXT_DOCUMENT_DID_OPEN, DidOpenTextDocumentParams
from lsprotocol.types import TEXT_DOCUMENT_DID_SAVE, DidSaveTextDocumentParams
from lsprotocol.types import TEXT_DOCUMENT_DEFINITION, DefinitionParams
from lsprotocol.types import TEXT_DOCUMENT_TYPE_DEFINITION, TypeDefinitionParams
from lsprotocol.types import TEXT_DOCUMENT_DECLARATION, DeclarationParams
from lsprotocol.types import TEXT_DOCUMENT_REFERENCES, ReferenceParams
from lsprotocol.types import (
    TEXT_DOCUMENT_COMPLETION,
    CompletionParams,
    CompletionOptions,
    CompletionList,
    CompletionItem,
    CompletionItemKind,
)
from lsprotocol.types import (
    TEXT_DOCUMENT_DOCUMENT_SYMBOL,
    DocumentSymbolParams,
    SymbolInformation,
    SymbolKind,
)
from lsprotocol.types import (
    TEXT_DOCUMENT_HOVER,
    HoverParams,
    Hover,
    MarkupContent,
    MarkupKind,
)
from lsprotocol.types import (
    WORKSPACE_DID_CHANGE_WORKSPACE_FOLDERS,
    DidChangeWorkspaceFoldersParams,
)
from lsprotocol.types import (
    INITIALIZE,
    InitializeParams,
)
from lsprotocol.types import (
    TEXT_DOCUMENT_CODE_ACTION,
    CodeActionParams,
    CodeAction,
    TextEdit,
    CodeActionKind,
    WorkspaceEdit,
)
from lsprotocol.types import (
    TEXT_DOCUMENT_INLAY_HINT,
    InlayHintParams,
    InlayHint,
    InlayHintLabelPart,
)
from lsprotocol.types import WORKSPACE_INLAY_HINT_REFRESH
from lsprotocol.types import WORKSPACE_SEMANTIC_TOKENS_REFRESH
from lsprotocol.types import TEXT_DOCUMENT_RENAME, RenameParams
from lsprotocol.types import (
    TEXT_DOCUMENT_DOCUMENT_HIGHLIGHT,
    DocumentHighlightParams,
    DocumentHighlight,
    DocumentHighlightKind,
)
from lsprotocol.types import (
    TEXT_DOCUMENT_CODE_LENS,
    CodeLensParams,
    CodeLens,
    Command,
)
from lsprotocol.types import (
    TEXT_DOCUMENT_SEMANTIC_TOKENS_FULL,
    SemanticTokensRegistrationOptions,
    SemanticTokensLegend,
    SemanticTokensParams,
    SemanticTokens,
    SemanticTokenTypes,
)

import argparse
import configargparse


def decl_kind(decl: chapel.NamedDecl) -> Optional[SymbolKind]:
    if isinstance(decl, chapel.Module) and decl.kind() != "implicit":
        return SymbolKind.Module
    elif isinstance(decl, chapel.Class):
        return SymbolKind.Class
    elif isinstance(decl, chapel.Record):
        return SymbolKind.Struct
    elif isinstance(decl, chapel.Interface):
        return SymbolKind.Interface
    elif isinstance(decl, chapel.Enum):
        return SymbolKind.Enum
    elif isinstance(decl, chapel.EnumElement):
        return SymbolKind.EnumMember
    elif isinstance(decl, chapel.Function):
        if decl.is_method():
            return SymbolKind.Method
        elif decl.name() in ("init", "init="):
            return SymbolKind.Constructor
        elif decl.kind() == "operator":
            return SymbolKind.Operator
        else:
            return SymbolKind.Function
    elif isinstance(decl, chapel.Variable):
        if decl.is_field():
            return SymbolKind.Field
        elif decl.intent() == "<const-var>":
            return SymbolKind.Constant
        elif decl.intent() == "type":
            return SymbolKind.TypeParameter
        else:
            return SymbolKind.Variable
    return None


def decl_kind_to_completion_kind(kind: SymbolKind) -> CompletionItemKind:
    conversion_map = {
        SymbolKind.Module: CompletionItemKind.Module,
        SymbolKind.Class: CompletionItemKind.Class,
        SymbolKind.Struct: CompletionItemKind.Struct,
        SymbolKind.Interface: CompletionItemKind.Interface,
        SymbolKind.Enum: CompletionItemKind.Enum,
        SymbolKind.EnumMember: CompletionItemKind.EnumMember,
        SymbolKind.Method: CompletionItemKind.Method,
        SymbolKind.Constructor: CompletionItemKind.Constructor,
        SymbolKind.Operator: CompletionItemKind.Operator,
        SymbolKind.Function: CompletionItemKind.Function,
        SymbolKind.Field: CompletionItemKind.Field,
        SymbolKind.Constant: CompletionItemKind.Constant,
        SymbolKind.TypeParameter: CompletionItemKind.TypeParameter,
        SymbolKind.Variable: CompletionItemKind.Variable,
    }
    return conversion_map[kind]


def completion_item_for_decl(
    decl: chapel.NamedDecl,
) -> Optional[CompletionItem]:
    kind = decl_kind(decl)
    if not kind:
        return None

    return CompletionItem(
        label=decl.name(),
        kind=decl_kind_to_completion_kind(kind),
        insert_text=decl.name(),
        sort_text=decl.name(),
    )


def location_to_location(loc) -> Location:
    return Location("file://" + loc.path(), location_to_range(loc))


def get_symbol_information(
    decl: chapel.NamedDecl,
) -> Optional[SymbolInformation]:
    loc = location_to_location(decl.location())
    kind = decl_kind(decl)
    if kind:
        # TODO: should we use DocumentSymbol or SymbolInformation? LSP spec says
        # prefer DocumentSymbol, but nesting doesn't work out of the box.
        # implies that we need some kind of visitor pattern to build a DS tree
        # using symbol information for now, as it sort-of autogets the tree
        # structure
        is_deprecated = chapel.is_deprecated(decl)
        name = get_symbol_signature(decl)
        return SymbolInformation(loc, name, kind, deprecated=is_deprecated)
    return None


def range_to_tokens(
    rng: chapel.Location, lines: List[str]
) -> List[Tuple[int, int, int]]:
    """
    Convert a Chapel location to a list of token-compatible ranges. If a location
    spans multiple lines, it gets split into multiple tokens. The lines
    and columns are zero-indexed.

    Returns a list of (line, column, length).
    """

    (line_start, char_start) = rng.start()
    (line_end, char_end) = rng.end()

    if line_start == line_end:
        return [(line_start - 1, char_start - 1, char_end - char_start)]

    tokens = [
        (
            line_start - 1,
            char_start - 1,
            len(lines[line_start - 1]) - char_start,
        )
    ]
    for line in range(line_start + 1, line_end):
        tokens.append((line - 1, 0, len(lines[line - 1])))
    tokens.append((line_end - 1, 0, char_end - 1))

    return tokens


def encode_deltas(
    tokens: List[Tuple[int, int, int]], token_type: int, token_modifiers: int
) -> List[int]:
    """
    Given a (non-encoded) list of token positions, applies the LSP delta-encoding
    to it: each line is encoded as a delta from the previous line, and each
    column is encoded as a delta from the previous column.

    Returns tokens with type token_type, and modifiers token_modifiers.
    """

    encoded = []
    last_line = None
    last_col = 0
    for line, start, length in tokens:
        backup = line
        if line == last_line:
            start -= last_col
        if last_line is not None:
            line -= last_line
        last_line = backup

        encoded.extend([line, start, length, token_type, token_modifiers])
    return encoded


EltT = TypeVar("EltT")


@dataclass
class PositionList(Generic[EltT]):
    get_range: Callable[[EltT], Range]
    elts: List[EltT] = field(default_factory=list)

    def sort(self):
        self.elts.sort(key=lambda x: self.get_range(x).start)

    def append(self, elt: EltT):
        self.elts.append(elt)

    def _get_range(self, rng: Range):
        start = bisect_left(
            self.elts, rng.start, key=lambda x: self.get_range(x).start
        )
        end = bisect_right(
            self.elts, rng.end, key=lambda x: self.get_range(x).start
        )
        return (start, end)

    def overwrite(self, elt: EltT):
        rng = self.get_range(elt)
        start, end = self._get_range(rng)
        self.elts[start:end] = [elt]

    def clear(self):
        self.elts.clear()

    def find(self, pos: Position) -> Optional[EltT]:
        idx = bisect_right(
            self.elts, pos, key=lambda x: self.get_range(x).start
        )
        idx -= 1
        if idx < 0 or pos > self.get_range(self.elts[idx]).end:
            return None
        return self.elts[idx]

    def range(self, rng: Range) -> List[EltT]:
        start, end = self._get_range(rng)
        return self.elts[start:end]


@dataclass
class NodeAndRange:
    node: chapel.AstNode
    rng: Range = field(init=False)

    def __post_init__(self):
        if isinstance(self.node, chapel.Dot):
            self.rng = location_to_range(self.node.field_location())
        elif isinstance(
            self.node,
            (chapel.Formal, chapel.Module, chapel.TypeDecl),
        ):
            self.rng = location_to_range(self.node.name_location())
        else:
            # TODO: Some NamedDecls are not reported using name_location().
            #       This is because name_location() is not correctly reported
            #       by the parser today.
            self.rng = location_to_range(self.node.location())

    def get_location(self):
        return Location(self.get_uri(), self.rng)

    def get_uri(self):
        path = self.node.location().path()
        return f"file://{path}"


@dataclass
class ResolvedPair:
    ident: NodeAndRange
    resolved_to: NodeAndRange


class ContextContainer:
    def __init__(self, file: str, config: Optional["WorkspaceConfig"]):
        self.file_paths: List[str] = []
        self.module_paths: List[str] = [file]
        self.context: chapel.Context = chapel.Context()
        self.file_infos: List["FileInfo"] = []

        if config:
            file_config = config.for_file(file)
            if file_config:
                self.module_paths = file_config["module_dirs"]
                self.file_paths = file_config["files"]

        self.context.set_module_paths(self.module_paths, self.file_paths)

    def new_file_info(
        self, uri: str, use_resolver: bool
    ) -> Tuple["FileInfo", List[Any]]:
        """
        Creates a new FileInfo for a given URI. FileInfos constructed in
        this manner are tied to this ContextContainer, and have their
        indices rebuilt when the context updates. They also use
        this context object to perform parsing etc.
        """

        with self.context.track_errors() as errors:
            fi = FileInfo(uri, self, use_resolver)
            self.file_infos.append(fi)
        return (fi, errors)

    def advance(self) -> List[Any]:
        """
        Advances the Dyno context within to the next revision, and takes
        care of setting the necessary input queries in this revision. All
        dependent FileInfos are also updated since the file contents
        they represent may have changed.
        """

        self.context.advance_to_next_revision(False)
        self.context.set_module_paths(self.module_paths, self.file_paths)

        with self.context.track_errors() as errors:
            for fi in self.file_infos:
                fi.rebuild_index()
        return errors


@dataclass
@visitor
class FileInfo:
    uri: str
    context: ContextContainer
    use_resolver: bool
    use_segments: PositionList[ResolvedPair] = field(init=False)
    def_segments: PositionList[NodeAndRange] = field(init=False)
    instantiation_segments: PositionList[
        Tuple[NodeAndRange, chapel.TypedSignature]
    ] = field(init=False)
    uses_here: Dict[str, List[NodeAndRange]] = field(init=False)
    instantiations: Dict[str, Set[chapel.TypedSignature]] = field(init=False)
    siblings: chapel.SiblingMap = field(init=False)
    used_modules: List[chapel.Module] = field(init=False)
    possibly_visible_decls: List[chapel.NamedDecl] = field(init=False)

    def __post_init__(self):
        self.use_segments = PositionList(lambda x: x.ident.rng)
        self.def_segments = PositionList(lambda x: x.rng)
        self.instantiation_segments = PositionList(lambda x: x[0].rng)
        self.rebuild_index()

    def parse_file(self) -> List[chapel.AstNode]:
        """
        Parses this file and returns the toplevel ast elements

        Note: if there are errors they will be printed to the console.
        This call should be wrapped an appropriate error context.
        """

        return self.context.context.parse(self.uri[len("file://") :])

    def get_asts(self) -> List[chapel.AstNode]:
        """
        Returns toplevel ast elements. This method silences all errors.
        """
        with self.context.context.track_errors() as _:
            return self.parse_file()

    def _note_reference(self, node: Union[chapel.Dot, chapel.Identifier]):
        """
        Given a node that can refer to another node, note what it refers
        to in by updating the 'use' segment table and the list of uses.
        """
        to = node.to_node()
        if not to:
            return

        self.uses_here[to.unique_id()].append(NodeAndRange(node))
        self.use_segments.append(
            ResolvedPair(NodeAndRange(node), NodeAndRange(to))
        )

    @enter
    def _enter_Identifier(self, node: chapel.Identifier):
        self._note_reference(node)

    @enter
    def _enter_Dot(self, node: chapel.Dot):
        self._note_reference(node)

    @enter
    def _enter_NamedDecl(self, node: chapel.NamedDecl):
        self.def_segments.append(NodeAndRange(node))

    def _collect_used_modules(self, asts: List[chapel.AstNode]):
        self.used_modules = []
        for ast in asts:
            scope = ast.scope()
            if scope:
                self.used_modules.extend(scope.used_imported_modules())

    def _collect_possibly_visible_decls(self):
        self.possibly_visible_decls = []
        for mod in self.used_modules:
            for child in mod:
                if not isinstance(child, chapel.NamedDecl):
                    continue

                if child.visibility() == "private":
                    continue

                self.possibly_visible_decls.append(child)

    def _search_instantiations(
        self, root: Union[chapel.AstNode, List[chapel.AstNode]], via: Optional[chapel.TypedSignature] = None
    ):
        for node in chapel.preorder(root):
            if not isinstance(node, chapel.FnCall):
                continue

            rr = node.resolve_via(via) if via else node.resolve()
            if not rr:
                continue

            candidate = rr.most_specific_candidate()
            if not candidate:
                continue

            sig = candidate.function()
            fn = sig.ast()

            insts = self.instantiations[fn.unique_id()]
            if not sig.is_instantiation() or sig in insts:
                continue

            insts.add(sig)
            self._search_instantiations(fn, via=sig)

    def rebuild_index(self):
        """
        Rebuild the cached line info and siblings information

        Note: this is a potentially expensive operation, it should only be done
        when advancing the revision
        """
        asts = self.parse_file()

        # Use this class as an AST visitor to rebuild the use and definition segment
        # table, as well as the list of references.
        self.uses_here = defaultdict(list)
        self.instantiations = defaultdict(set)
        self.use_segments.clear()
        self.def_segments.clear()
        self.visit(asts)
        self.use_segments.sort()
        self.def_segments.sort()

        self.siblings = chapel.SiblingMap(asts)
        self._collect_used_modules(asts)
        self._collect_possibly_visible_decls()

        if self.use_resolver:
            with self.context.context.track_errors() as _:
                self._search_instantiations(asts)

    def get_use_segment_at_position(
        self, position: Position
    ) -> Optional[ResolvedPair]:
        """lookup a use segment based upon a Position, likely a user mouse location"""
        return self.use_segments.find(position)

    def get_def_segment_at_position(
        self, position: Position
    ) -> Optional[NodeAndRange]:
        """lookup a def segment based upon a Position, likely a user mouse location"""
        return self.def_segments.find(position)

    def get_inst_segment_at_position(
        self, position: Position
    ) -> Optional[chapel.TypedSignature]:
        """lookup a def segment based upon a Position, likely a user mouse location"""
        segment = self.instantiation_segments.find(position)
        if segment:
            return segment[1]
        return None

    def get_use_or_def_segment_at_position(
        self, position: Position
    ) -> Optional[NodeAndRange]:
        """
        Retrieve the definition or reference to a definition at the given position.
        This method is intended for LSP queries that ask for some property
        of a definition: its type, references to it, etc. However, it is
        convenient to be able to "find references" and "go to type definition"
        from references to a definition too. Thus, this method returns
        a definition when it can, and falls back to references otherwise.
        """

        segment = self.get_def_segment_at_position(position)
        if segment:
            return segment
        else:
            segment = self.get_use_segment_at_position(position)
            if segment:
                return segment.resolved_to

        return None

    def file_lines(self) -> List[str]:
        file_text = self.context.context.get_file_text(
            self.uri[len("file://") :]
        )
        return file_text.splitlines()


class WorkspaceConfig:
    def __init__(self, ls: "ChapelLanguageServer", json: Dict[str, Any]):
        self.files: Dict[str, Dict[str, Any]] = {}

        for key in json:
            compile_commands = json[key]

            if not isinstance(compile_commands, list):
                ls.show_message(
                    "invalid .cls-commands.json file", MessageType.Error
                )
                continue

            # There can be several compile commands. They can conflict,
            # so we can't safely merge them (chpl -M modulesA and chpl -M modulesB
            # can lead to two different to-IDs etc.). However, we do expect
            # at least one compile command.
            if len(compile_commands) == 0:
                ls.show_message(
                    ".cls-commands.json file contains invalid file commands",
                    MessageType.Error,
                )
                continue

            self.files[key] = compile_commands[0]

    def for_file(self, path: str) -> Optional[Dict[str, Any]]:
        if path in self.files:
            return self.files[path]
        return None

    @staticmethod
    def from_file(ls: "ChapelLanguageServer", path: str):
        if os.path.exists(path):
            with open(path) as f:
                commands = json.load(f)
                return WorkspaceConfig(ls, commands)
        return None


class ChapelLanguageServer(LanguageServer):
    def __init__(self, config: argparse.Namespace):
        super().__init__("chpl-language-server", "v0.1")

        self.contexts: Dict[str, ContextContainer] = {}
        self.file_infos: Dict[str, FileInfo] = {}
        self.configurations: Dict[str, WorkspaceConfig] = {}

        self.use_resolver: bool = config.resolver
        self.type_inlays: bool = config.type_inlays
        self.literal_arg_inlays: bool = config.literal_arg_inlays
        self.param_inlays: bool = config.param_inlays
        self.dead_code: bool = config.dead_code

        self._setup_regexes()

    def _setup_regexes(self):
        """
        sets up regular expressions for use in text replacement for code actions
        """
        prefix = "Warning: \\[Deprecation\\]:"
        chars = "[a-zA-Z0-9_.:;,'`\\- ]*?"
        ident = "[a-zA-Z0-9_.()]+?"
        pat1 = f"{prefix}{chars}(?:'(?P<original1>{ident})'{chars})?'(?P<replace1>{ident})'{chars}"
        pat2 = f"{prefix}{chars}use{chars}(?P<tick>[`' ])(?P<replace2>{ident})(?P=tick){chars}instead{chars}"
        # use pat2 first since it is more specific
        self._find_rename_deprecation_regex = re.compile(f"({pat2})|({pat1})")

    def get_deprecation_replacement(
        self, text: str
    ) -> Tuple[Optional[str], Optional[str]]:
        """
        Given a deprecation warning message, return the string to replace the deprecation with if possible
        """

        m = re.match(self._find_rename_deprecation_regex, text)
        if m and (m.group("replace1") or m.group("replace2")):
            replacement = m.group("replace1") or m.group("replace2")
            original = None
            if m.group("original1"):
                original = m.group("original1")
            return (original, replacement)

        return (None, None)

    def get_config_for_uri(self, uri: str) -> Optional[WorkspaceConfig]:
        """
        In case multiple workspace folders are in use, pick the root folder
        that matches the given URI.
        """

        folders = self.workspace.folders
        for f, ws in folders.items():
            if uri.startswith(f):
                uri = ws.uri
                if uri in self.configurations:
                    return self.configurations[uri]
        return None

    def get_context(self, uri: str) -> ContextContainer:
        """
        Get the Chapel context for a given URI. Creating a new context
        for a file associates it with the file, as well as with any
        files that are associated with the file. For instance, if
        A.chpl imports B.chpl, and a context is created for either A.chpl
        or B.chpl, both files are associated with this new context.
        """

        path = uri[len("file://") :]
        workspace_config = self.get_config_for_uri(uri)

        if path in self.contexts:
            return self.contexts[path]

        context = ContextContainer(path, workspace_config)
        for file in context.file_paths:
            self.contexts[file] = context
        self.contexts[path] = context

        return context

    def get_file_info(
        self, uri: str, do_update: bool = False
    ) -> Tuple[FileInfo, List[Any]]:
        """
        The language server maintains a FileInfo object per file. The FileInfo
        contains precomputed information (binary-search-ready tables for
        finding an element under a cursor).

        This method retrieves the FileInfo object for a particular URI,
        creating one if it doesn't exist. If do_update is set to True,
        then the FileInfo's index is reuilt even if it has already been
        computed. This is useful if the underlying file has changed.
        """

        errors = []

        if uri in self.file_infos:
            file_info = self.file_infos[uri]
            if do_update:
                errors = file_info.context.advance()
        else:
            file_info, errors = self.get_context(uri).new_file_info(
                uri, self.use_resolver
            )
            self.file_infos[uri] = file_info

        return (file_info, errors)

    def build_diagnostics(self, uri: str) -> List[Diagnostic]:
        """
        Parse a file at a particular URI, capture the errors, and return then
        as a list of LSP Diagnostics.
        """

        _, errors = self.get_file_info(uri, do_update=True)

        diagnostics = [error_to_diagnostic(e) for e in errors]
        return diagnostics

    def get_text(self, text_doc: TextDocument, rng: Range) -> str:
        """
        Get the text of a TextDocument within a Range
        """
        start_line = rng.start.line
        stop_line = rng.end.line
        if start_line == stop_line:
            return text_doc.lines[start_line][
                rng.start.character : rng.end.character
            ]
        else:
            lines = text_doc.lines[start_line : stop_line + 1]
            lines[0] = lines[0][rng.start.character :]
            lines[-1] = lines[-1][: rng.end.character]
            return "\n".join(lines)

    def register_workspace(self, uri: str):
        path = os.path.join(uri[len("file://") :], ".cls-commands.json")
        config = WorkspaceConfig.from_file(self, path)
        if config:
            self.configurations[uri] = config

    def unregister_workspace(self, uri: str):
        if uri in self.configurations:
            del self.configurations[uri]

    def _get_param_inlays(
        self, decl: NodeAndRange, qt: chapel.QualifiedType
    ) -> List[InlayHint]:
        if not self.param_inlays:
            return []

        _, _, param = qt
        if not param:
            return []

        return [
            InlayHint(
                position=decl.rng.end,
                label="param value is " + str(param),
                padding_left=True,
            )
        ]

    def _get_type_inlays(
        self,
        decl: NodeAndRange,
        qt: chapel.QualifiedType,
        siblings: chapel.SiblingMap,
    ) -> List[InlayHint]:
        if not self.type_inlays:
            return []

        # Only show type hints for variable declarations that don't have
        # an explicit type, and whose type is valid.
        _, type_, _ = qt
        if (
            not isinstance(decl.node, (chapel.Variable, chapel.Formal))
            or decl.node.type_expression() is not None
            or isinstance(type_, chapel.ErroneousType)
        ):
            return []

        name_rng = location_to_range(decl.node.name_location())
        type_str = ": " + str(type_)
        colon_label = InlayHintLabelPart(": ")
        label = InlayHintLabelPart(str(type_))
        if isinstance(type_, chapel.CompositeType):
            typedecl = type_.decl()

            if typedecl:
                text = self.get_tooltip(typedecl, siblings)
                content = MarkupContent(MarkupKind.Markdown, text)
                label.tooltip = content
                label.location = location_to_location(typedecl.location())

        return [
            InlayHint(
                position=name_rng.end,
                label=[colon_label, label],
                text_edits=[
                    TextEdit(Range(name_rng.end, name_rng.end), type_str)
                ],
            )
        ]

    def get_decl_inlays(
        self,
        decl: NodeAndRange,
        siblings: chapel.SiblingMap,
        via: Optional[chapel.TypedSignature] = None,
    ) -> List[InlayHint]:
        if not self.use_resolver:
            return []

        rr = decl.node.resolve_via(via) if via else decl.node.resolve()
        if not rr:
            return []

        qt = rr.type()
        if qt is None:
            return []

        inlays = []
        inlays.extend(self._get_param_inlays(decl, qt))
        inlays.extend(self._get_type_inlays(decl, qt, siblings))
        return inlays

    def get_call_inlays(
        self, call: chapel.FnCall, via: Optional[chapel.TypedSignature] = None
    ) -> List[InlayHint]:
        if not self.literal_arg_inlays or not self.use_resolver:
            return []

        rr = call.resolve_via(via) if via else call.resolve()
        if not rr:
            return []

        msc = rr.most_specific_candidate()
        if not msc:
            return []

        fn = msc.function().ast()
        if not fn or not isinstance(fn, chapel.core.Function):
            return []

        inlays = []
        for i, act in zip(msc.formal_actual_mapping(), call.actuals()):
            if not isinstance(act, chapel.core.AstNode):
                # Named arguments are represented using (name, node)
                # tuples. We don't need hints for those.
                continue

            if not isinstance(act, chapel.core.Literal):
                # Only show named arguments for literals.
                continue

            fml = fn.formal(i)
            if not isinstance(fml, chapel.core.Formal):
                continue

            begin = location_to_range(act.location()).start
            inlays.append(
                InlayHint(
                    position=begin,
                    label=fml.name() + " = ",
                )
            )

        return inlays

    def get_tooltip(
        self, node: chapel.AstNode, siblings: chapel.SiblingMap
    ) -> str:
        signature = get_symbol_signature(node)
        docstring = chapel.get_docstring(node, siblings)
        text = f"```chapel\n{signature}\n```"
        if docstring:
            text += f"\n---\n{docstring}"
        return text

    def get_dead_code_tokens(
        self,
        node: chapel.Conditional,
        lines: list[str],
        via: Optional[chapel.TypedSignature] = None,
    ) -> List[Tuple[int, int, int]]:
        if not self.dead_code or not self.use_resolver:
            return []

        rr = (
            node.condition().resolve_via(via)
            if via
            else node.condition().resolve()
        )
        if not rr:
            return []

        qt = rr.type()
        if qt is None:
            return []

        _, _, val = qt
        if isinstance(val, chapel.BoolParam):
            dead_branch = (
                node.else_block() if val.value() else node.then_block()
            )
            if dead_branch:
                loc = dead_branch.location()
                return range_to_tokens(loc, lines)

        return []


def run_lsp():
    """
    Start a language server on the standard input/output
    """
    parser = configargparse.ArgParser(
        default_config_files=[],  # Empty for now because cwd() is odd with VSCode etc.
        config_file_parser_class=configargparse.YAMLConfigFileParser,
    )

    def add_bool_flag(name: str, dest: str, default: bool):
        parser.add_argument(f"--{name}", dest=dest, action="store_true")
        parser.add_argument(f"--no-{name}", dest=dest, action="store_false")
        parser.set_defaults(**{dest: default})

    add_bool_flag("resolver", "resolver", False)
    add_bool_flag("type-inlays", "type_inlays", True)
    add_bool_flag("param-inlays", "param_inlays", True)
    add_bool_flag("literal-arg-inlays", "literal_arg_inlays", True)
    add_bool_flag("dead-code", "dead_code", True)

    server = ChapelLanguageServer(parser.parse_args())

    # The following functions are handlers for LSP events received by the server.

    @server.feature(INITIALIZE)
    async def initialize(
        ls: ChapelLanguageServer,
        params: InitializeParams,
    ):
        if params.workspace_folders is None:
            return

        for ws in params.workspace_folders:
            ls.register_workspace(ws.uri)

    @server.feature(WORKSPACE_DID_CHANGE_WORKSPACE_FOLDERS)
    async def did_change_folders(
        ls: ChapelLanguageServer,
        params: DidChangeWorkspaceFoldersParams,
    ):
        for added in params.event.added:
            ls.register_workspace(added.uri)
        for removed in params.event.removed:
            ls.unregister_workspace(removed.uri)

    @server.feature(TEXT_DOCUMENT_DID_OPEN)
    @server.feature(TEXT_DOCUMENT_DID_SAVE)
    async def did_save(
        ls: ChapelLanguageServer,
        params: Union[DidSaveTextDocumentParams, DidOpenTextDocumentParams],
    ):
        text_doc = ls.workspace.get_text_document(params.text_document.uri)
        diag = ls.build_diagnostics(text_doc.uri)
        ls.publish_diagnostics(text_doc.uri, diag)
        ls.lsp.send_request_async(WORKSPACE_INLAY_HINT_REFRESH)
        ls.lsp.send_request_async(WORKSPACE_SEMANTIC_TOKENS_REFRESH)

    @server.feature(TEXT_DOCUMENT_DECLARATION)
    @server.feature(TEXT_DOCUMENT_DEFINITION)
    async def get_def(
        ls: ChapelLanguageServer,
        params: Union[DefinitionParams, DeclarationParams],
    ):
        text_doc = ls.workspace.get_text_document(params.text_document.uri)

        fi, _ = ls.get_file_info(text_doc.uri)
        segment = fi.get_use_segment_at_position(params.position)
        if segment:
            return segment.resolved_to.get_location()
        return None

    @server.feature(TEXT_DOCUMENT_REFERENCES)
    async def get_refs(ls: ChapelLanguageServer, params: ReferenceParams):
        text_doc = ls.workspace.get_text_document(params.text_document.uri)

        fi, _ = ls.get_file_info(text_doc.uri)

        node_and_loc = fi.get_use_or_def_segment_at_position(params.position)
        if not node_and_loc:
            return None

        locations = [node_and_loc.get_location()]
        for use in fi.uses_here[node_and_loc.node.unique_id()]:
            locations.append(use.get_location())

        return locations

    @server.feature(TEXT_DOCUMENT_TYPE_DEFINITION)
    async def get_type_def(
        ls: ChapelLanguageServer, params: TypeDefinitionParams
    ):
        if not ls.use_resolver:
            return None

        text_doc = ls.workspace.get_text_document(params.text_document.uri)

        fi, _ = ls.get_file_info(text_doc.uri)

        node_and_loc = fi.get_use_or_def_segment_at_position(params.position)
        if not node_and_loc:
            return None

        qt = node_and_loc.node.type()
        if qt is None:
            return None

        _, type_, _ = qt
        if not isinstance(type_, chapel.CompositeType):
            return None

        decl = type_.decl()
        return location_to_location(decl.location())

    @server.feature(TEXT_DOCUMENT_DOCUMENT_SYMBOL)
    async def get_sym(ls: ChapelLanguageServer, params: DocumentSymbolParams):
        text_doc = ls.workspace.get_text_document(params.text_document.uri)

        fi, _ = ls.get_file_info(text_doc.uri)

        # doesn't descend into nested definitions for Functions
        def preorder_ignore_funcs(node):
            yield node
            if isinstance(node, chapel.Function):
                return
            for child in node:
                yield from preorder_ignore_funcs(child)

        syms = []
        for node, _ in chapel.each_matching(
            fi.get_asts(),
            chapel.NamedDecl,
            iterator=preorder_ignore_funcs,
        ):
            si = get_symbol_information(node)
            if si:
                syms.append(si)

        return syms

    @server.feature(TEXT_DOCUMENT_HOVER)
    async def hover(ls: ChapelLanguageServer, params: HoverParams):
        text_doc = ls.workspace.get_text_document(params.text_document.uri)

        fi, _ = ls.get_file_info(text_doc.uri)
        segment = fi.get_use_segment_at_position(params.position)
        if not segment:
            return None
        resolved_to = segment.resolved_to
        node_fi, _ = ls.get_file_info(resolved_to.get_uri())

        text = ls.get_tooltip(resolved_to.node, node_fi.siblings)
        content = MarkupContent(MarkupKind.Markdown, text)
        return Hover(content, range=resolved_to.get_location().range)

    @server.feature(TEXT_DOCUMENT_COMPLETION, CompletionOptions())
    async def complete(ls: ChapelLanguageServer, params: CompletionParams):
        text_doc = ls.workspace.get_text_document(params.text_document.uri)

        fi, _ = ls.get_file_info(text_doc.uri)

        items = []
        items.extend(
            completion_item_for_decl(decl) for decl in fi.possibly_visible_decls
        )
        items.extend(completion_item_for_decl(mod) for mod in fi.used_modules)

        items = [item for item in items if item]

        return CompletionList(is_incomplete=False, items=items)

    @server.feature(TEXT_DOCUMENT_CODE_ACTION)
    async def code_action(ls: ChapelLanguageServer, params: CodeActionParams):
        text_doc = ls.workspace.get_text_document(params.text_document.uri)
        actions = []

        diagnostics_used: List[Diagnostic] = []
        edits_to_make: List[TextEdit] = []

        for d in params.context.diagnostics:
            original, replacement = ls.get_deprecation_replacement(d.message)
            if replacement is not None:
                full_text = ls.get_text(text_doc, d.range)
                if original is None:
                    original = full_text
                to_replace = full_text.replace(original, replacement)
                te = TextEdit(d.range, to_replace)
                msg = (
                    f"Resolve Deprecation: replace {original} with {to_replace}"
                )
                diagnostics_used.append(d)
                edits_to_make.append(te)
                ca = CodeAction(
                    msg,
                    CodeActionKind.QuickFix,
                    diagnostics=[d],
                    edit=WorkspaceEdit(changes={text_doc.uri: [te]}),
                )
                actions.append(ca)

        if len(edits_to_make) > 0:
            actions.append(
                CodeAction(
                    "Resolve Deprecations",
                    CodeActionKind.SourceFixAll,
                    diagnostics=diagnostics_used,
                    edit=WorkspaceEdit(changes={text_doc.uri: edits_to_make}),
                    is_preferred=True,
                )
            )

        return actions

    @server.feature(TEXT_DOCUMENT_RENAME)
    async def rename(ls: ChapelLanguageServer, params: RenameParams):
        text_doc = ls.workspace.get_text_document(params.text_document.uri)
        fi, _ = ls.get_file_info(text_doc.uri)

        node_and_loc = fi.get_use_or_def_segment_at_position(params.position)
        if not node_and_loc:
            return None

        edits: Dict[str, List[TextEdit]] = {}

        def add_to_edits(nr: NodeAndRange):
            if nr.get_uri() not in edits:
                edits[nr.get_uri()] = []
            edits[nr.get_uri()].append(TextEdit(nr.rng, params.new_name))

        add_to_edits(node_and_loc)
        for use in fi.uses_here[node_and_loc.node.unique_id()]:
            add_to_edits(use)

        return WorkspaceEdit(changes=edits)

    @server.feature(TEXT_DOCUMENT_INLAY_HINT)
    async def inlay_hint(ls: ChapelLanguageServer, params: InlayHintParams):
        # The get_decl_inlays and get_call_inlays methods also check
        # and return early if the resolver is not being used, but for
        # the time being all hints are resolver-based, so we may
        # as well save ourselves the work of finding declarations and
        # calls to feed to those methods.
        if not ls.use_resolver:
            return None

        text_doc = ls.workspace.get_text_document(params.text_document.uri)

        fi, _ = ls.get_file_info(text_doc.uri)

        decls = fi.def_segments.range(params.range)
        calls = list(
            call
            for call, _ in chapel.each_matching(
                fi.get_asts(), chapel.core.FnCall
            )
        )

        inlays: List[InlayHint] = []
        with fi.context.context.track_errors() as _:
            for decl in decls:
                instantiation = fi.get_inst_segment_at_position(decl.rng.start)
                inlays.extend(
                    ls.get_decl_inlays(decl, fi.siblings, instantiation)
                )

            for call in calls:
                instantiation = fi.get_inst_segment_at_position(
                    location_to_range(call.location()).start
                )
                inlays.extend(ls.get_call_inlays(call, instantiation))

        return inlays

    @server.feature(TEXT_DOCUMENT_DOCUMENT_HIGHLIGHT)
    async def document_highlight(
        ls: ChapelLanguageServer, params: DocumentHighlightParams
    ):
        text_doc = ls.workspace.get_text_document(params.text_document.uri)

        fi, _ = ls.get_file_info(text_doc.uri)

        node_and_loc = fi.get_use_or_def_segment_at_position(params.position)
        if not node_and_loc:
            return None

        # todo: it would be nice if this differentiated between read and write
        highlights = [
            DocumentHighlight(node_and_loc.rng, DocumentHighlightKind.Text)
        ]
        for use in fi.uses_here[node_and_loc.node.unique_id()]:
            highlights.append(
                DocumentHighlight(use.rng, DocumentHighlightKind.Text)
            )

        return highlights

    @server.feature(TEXT_DOCUMENT_CODE_LENS)
    async def code_lens(ls: ChapelLanguageServer, params: CodeLensParams):
        text_doc = ls.workspace.get_text_document(params.text_document.uri)

        fi, _ = ls.get_file_info(text_doc.uri)

        actions = []
        decls = fi.def_segments.elts
        for decl in decls:
            if (
                isinstance(decl.node, chapel.Function)
                and decl.node.unique_id() in fi.instantiations
            ):
                insts = fi.instantiations[decl.node.unique_id()]
                for i, inst in enumerate(insts):
                    action = CodeLens(
                        data=(decl.node.unique_id(), i),
                        command=Command(
                            "Show instantiation",
                            "chpl-language-server/showInstantiation",
                            [
                                params.text_document.uri,
                                decl.node.unique_id(),
                                i,
                            ],
                        ),
                        range=decl.rng,
                    )
                    actions.append(action)

        return actions

    @server.command("chpl-language-server/showInstantiation")
    async def show_instantiation(
        ls: ChapelLanguageServer, data: Tuple[str, str, int]
    ):
        uri, unique_id, i = data

        fi, _ = ls.get_file_info(uri)
        decl = next(
            decl
            for decl in fi.def_segments.elts
            if decl.node.unique_id() == unique_id
        )
        inst = list(fi.instantiations[unique_id])[i]
        fi.instantiation_segments.overwrite((decl, inst))

        ls.lsp.send_request_async(WORKSPACE_INLAY_HINT_REFRESH)
        ls.lsp.send_request_async(WORKSPACE_SEMANTIC_TOKENS_REFRESH)

    @server.feature(
        TEXT_DOCUMENT_SEMANTIC_TOKENS_FULL,
        options=SemanticTokensLegend(
            token_types=[SemanticTokenTypes.Comment], token_modifiers=[]
        ),
    )
    async def semantic_tokens_range(
        ls: ChapelLanguageServer, params: SemanticTokensParams
    ):
        if not ls.use_resolver:
            return None

        text_doc = ls.workspace.get_text_document(params.text_document.uri)

        fi, _ = ls.get_file_info(text_doc.uri)

        tokens = []

        for ast in chapel.postorder(fi.get_asts()):
            if isinstance(ast, chapel.core.Conditional):
                start_pos = location_to_range(ast.location()).start
                instantiation = fi.get_inst_segment_at_position(start_pos)
                tokens.extend(
                    ls.get_dead_code_tokens(
                        ast, fi.file_lines(), instantiation
                    )
                )

        return SemanticTokens(data=encode_deltas(tokens, 0, 0))

    server.start_io()


def main():
    run_lsp()


if __name__ == "__main__":
    main()
