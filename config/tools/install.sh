#!/bin/bash
echo "**** Fundraising Tools (Silverpop Export) setup"

# clone the code and set up githooks
clone_tools=$(ask_reclone "src/${TOOLS_SRC_DIR}" "Tools")
if [ $clone_tools = true ]; then
  echo "**** Cloning and setting up WMF tools repo in src/${TOOLS_SRC_DIR}"

  rm -rf src/${TOOLS_SRC_DIR}
  mkdir -p src/

  git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/wikimedia/fundraising/tools" \
    src/${TOOLS_SRC_DIR} && \
    scp $EXTRA_SCP_OPTION -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
    "src/${TOOLS_SRC_DIR}/.git/hooks/"
fi

# create required mysql databases
read -p "Create Silverpop & Silverpop test databases? [yN] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
	# Create SQL script
	cat << EOF > /tmp/tools_setup.sql
CREATE DATABASE IF NOT EXISTS test;
CREATE USER IF NOT EXISTS 'test'@'%';
GRANT ALL PRIVILEGES ON test.* TO 'test'@'%';
CREATE DATABASE IF NOT EXISTS silverpop;
EOF
  docker-compose exec -T database mysql < /tmp/tools_setup.sql
fi

echo "**** Fundraising Tools (Silverpop Export) setup complete"