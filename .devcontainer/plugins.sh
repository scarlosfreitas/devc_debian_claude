# claude skill add <pkg>: not a built-in claude CLI command, so shadow the
# real binary with a wrapper that adds it (see claude-wrapper.sh).
sudo install -m 0755 "$(dirname "$0")/claude-wrapper.sh" /usr/local/bin/claude

# Agent browser
sudo npm install -g agent-browser
sudo npm approve-scripts agent-browser  
agent-browser install --with-deps
claude skill add agent-browser

# Context7
claude mcp add context7 -- npx -y @upstash/context7-mcp

