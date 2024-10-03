"""Public API"""

load("@rules_python//python:defs.bzl", "py_test")
# load("@py_deps//:requirements.bzl", "requirement")

def py_pytest_test(name, srcs, deps = [], args = [], pytest_deps = [], **kwargs):
    """Use pytest to run tests, using a wrapper script to interface with Bazel.

    ```starlark
    py_pytest_test(
      name = "test_w_pytest",
      size = "small",
      srcs = ["test.py"],
    )
    ```

    By default, `@pip//pytest` is added to `deps`.
    If sharding is used (`shard_count > 1`) then `@pip//pytest_shard` is also added.
    To provide explicit deps for the pytest library, set `pytest_deps`:

    ```starlark
    py_pytest_test(
      name = "test_w_my_pytest",
      shard_count = 2,
      srcs = ["test.py"],
      pytest_deps = [requirement("pytest"), requirement("pytest-shard"), ...],
    )
    ```
    """
    shim_label = Label("//python_pytest:pytest_shim.py")

    if pytest_deps == None:
      pytest_deps = ["@pip//pytest"]
      if getattr(kwargs, "shard_count", 1) > 1:
        pytest_deps.append("@pip//pytest_shard")

    py_test(
        name = name,
        srcs = [
            shim_label,
        ] + srcs,
        main = shim_label,
        args = [
            "--capture=no",
        ] + args + ["$(location :%s)" % x for x in srcs],
        # python_version = "PY3",
        # srcs_version = "PY3",
        deps = deps + pytest_deps,
        **kwargs
    )
