#!/bin/bash

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

cat <<EOF >  "${THIS_DIR}/.git/hooks/pre-commit"
#!/bin/bash

set -e

echo "Running validations..."
./run-shellcheck.sh
EOF

chmod a+x "${THIS_DIR}/.git/hooks/pre-commit"