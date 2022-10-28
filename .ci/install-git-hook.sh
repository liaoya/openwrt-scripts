#!/bin/bash

if git rev-parse --show-toplevel 1>/dev/null 2>&1; then
    ROOT_DIR=$(git rev-parse --show-toplevel)
    THIS_DIR=$(readlink -f "${BASH_SOURCE[0]}")
    THIS_DIR=$(dirname "${THIS_DIR}")
    THIS_DIR=${THIS_DIR:${#ROOT_DIR}+1}

    cat <<EOF | tee "${ROOT_DIR}/.git/hooks/pre-commit"
#!/bin/bash

set -e

ROOT_DIR=\$(git rev-parse --show-toplevel)

echo "Running validations..."
"\${ROOT_DIR}/${THIS_DIR}/run-shellcheck.sh" "\${ROOT_DIR}"
if command -v shfmt >/dev/null 2>&1 && [[ -n \$(shfmt -i 4 -d "\${ROOT_DIR}") ]]; then
    echo "Fail to run shfmt check, stage your change and run 'shfmt -i 4 -w \${ROOT_DIR}'"
    exit 1
fi
EOF

    chmod a+x "${ROOT_DIR}/.git/hooks/pre-commit"
fi
