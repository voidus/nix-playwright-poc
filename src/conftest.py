import os
from typing import Dict, Optional

import playwright
import pytest


@pytest.fixture(scope="session")
def browser_type_launch_args(
    browser_name: Optional[str], browser_type_launch_args: Dict
) -> Dict:
    assert browser_name
    assert (
        os.environ["POC_PLAYWRIGHT_VERSION"] == playwright._repo_version.version  # type: ignore
    ), "Mismatched playwright browsers, did you update playwright without fixing the version in shell.nix?"

    env_var = f"POC_PLAYWRIGHT_{browser_name.upper()}"
    browser_type_launch_args["executable_path"] = os.environ[env_var]
    return browser_type_launch_args
