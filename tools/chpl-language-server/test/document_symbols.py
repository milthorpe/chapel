"""
Test that document symbols are reported properly.
"""

import sys

from lsprotocol.types import ClientCapabilities
from lsprotocol.types import InitializeParams
import pytest
import pytest_lsp
from pytest_lsp import ClientServerConfig, LanguageClient

from util.utils import *
from util.config import CLS_PATH


@pytest_lsp.fixture(
    config=ClientServerConfig(
        server_command=[sys.executable, CLS_PATH()],
        client_factory=get_base_client,
    )
)
async def client(lsp_client: LanguageClient):
    # Setup
    params = InitializeParams(capabilities=ClientCapabilities())
    await lsp_client.initialize_session(params)

    yield

    # Teardown
    await lsp_client.shutdown_session()


@pytest.mark.asyncio
async def test_document_symbols(client: LanguageClient):
    """
    Test that document symbols returns the correct symbols
    """
    file = """
            module M {
              const a = 10;
              var b = 11;
              param c = 12;
              config var d = 13;
              type T = string;
              proc foo(const a) { }
              record myRecord {
                type t = int;
                param p = 17;
                const c: t = 18;
                var x: t;
                proc init() { }
                proc foo() { }
                operator +(a: myRecord, b: myRecord): myRecord { return a; }
              }
              proc myRecord.bar() { }
              class MyClass { }

              enum myEnum {
                a,
                b
              }
            }
            """

    symbols = [
        (rng((0, 0), (23, 1)), "module M", SymbolKind.Module),
        (rng((1, 8), (1, 14)), "const a = 10", SymbolKind.Constant),
        (rng((2, 6), (2, 12)), "var b = 11", SymbolKind.Variable),
        (rng((3, 8), (3, 14)), "param c = 12", SymbolKind.Constant),
        (rng((4, 13), (4, 19)), "config var d = 13", SymbolKind.Variable),
        (rng((5, 7), (5, 17)), "type T = string", SymbolKind.TypeParameter),
        (rng((6, 2), (6, 23)), "proc foo(const a)", SymbolKind.Function),
        (rng((7, 2), (15, 3)), "record myRecord", SymbolKind.Struct),
        (rng((8, 9), (8, 16)), "type t = int", SymbolKind.TypeParameter),
        (rng((9, 10), (9, 16)), "param p = 17", SymbolKind.Constant),
        (rng((10, 10), (10, 19)), "const c: t = 18", SymbolKind.Field),
        (rng((11, 8), (11, 13)), "var x: t", SymbolKind.Field),
        (rng((12, 4), (12, 19)), "proc init()", SymbolKind.Constructor),
        (rng((13, 4), (13, 18)), "proc foo()", SymbolKind.Method),
        (
            rng((14, 4), (14, 64)),
            "operator +(a: myRecord, b: myRecord): myRecord",
            SymbolKind.Operator,
        ),
        (rng((16, 2), (16, 25)), "proc bar()", SymbolKind.Method),
        (rng((17, 2), (17, 19)), "class MyClass", SymbolKind.Class),
        (rng((19, 2), (22, 3)), "enum myEnum", SymbolKind.Enum),
        (rng((20, 4), (20, 5)), "a", SymbolKind.EnumMember),
        (rng((21, 4), (21, 5)), "b", SymbolKind.EnumMember),
    ]

    async with source_file(client, file, 0) as doc:
        await check_symbol_information(client, doc, symbols)


@pytest.mark.asyncio
@pytest.mark.xfail
async def test_document_symbols_var(client: LanguageClient):
    """
    Test that `var` is included in the location
    """
    file = """
            var x = 10;
            """

    symbols = [
        (rng((0, 0), (0, 10)), "var x = 10", SymbolKind.Variable),
    ]

    async with source_file(client, file, 0) as doc:
        await check_symbol_information(client, doc, symbols)


@pytest.mark.asyncio
async def test_document_symbols_deprecated(client: LanguageClient):
    """
    Test that deprecated symbols are marked as such
    """
    file = """
            @deprecated()
            var x = 10;
            """

    symbols = [(rng((1, 4), (1, 10)), "var x = 10", SymbolKind.Variable)]

    async with source_file(client, file, 0) as doc:
        symbols = await check_symbol_information(client, doc, symbols)
        assert len(symbols) == 1
        assert symbols[0].deprecated


@pytest.mark.asyncio
async def test_document_symbols_nested(client: LanguageClient):
    """
    Test that nested symbols are not reported
    """
    file = """
            proc foo() {
              proc nested() { }
              var a = 10;
            }
            """

    symbols = [(rng((0, 0), (3, 1)), "proc foo()", SymbolKind.Function)]

    async with source_file(client, file, 0) as doc:
        await check_symbol_information(client, doc, symbols)
