"""
Test basic functionality when `--resolver` is used.

Note: when this becomes the default, these tests should be folded into `basic.py`
"""

import sys

from lsprotocol.types import ClientCapabilities
from lsprotocol.types import CompletionList, CompletionParams
from lsprotocol.types import ReferenceParams, ReferenceContext
from lsprotocol.types import InitializeParams
import pytest
import pytest_lsp
from pytest_lsp import ClientServerConfig, LanguageClient

from util.utils import *
from util.config import CLS_PATH


@pytest_lsp.fixture(
    config=ClientServerConfig(
        server_command=[sys.executable, CLS_PATH(), "--resolver"]
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
async def test_go_to_record_def(client: LanguageClient):
    """
    Ensure that 'go to definition' on a type actually works.
    """

    file = """
           record myRec {}
           var x: myRec;
           var y = new myRec();
           var z = y;
           """

    with source_file(client, file) as doc:
        await check_goto_decl_def(client, doc, pos((0, 7)), pos((0, 7)))
        await check_goto_decl_def(client, doc, pos((1, 7)), pos((0, 7)))
        await check_goto_decl_def(client, doc, pos((2, 12)), pos((0, 7)))
        await check_goto_type_def(client, doc, pos((2,4)), pos((0,7)))
        await check_goto_type_def(client, doc, pos((3,9)), pos((0,7)))

        assert len(client.diagnostics) == 0
