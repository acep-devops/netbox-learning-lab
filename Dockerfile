FROM netboxcommunity/netbox:latest

COPY plugin_requirements.txt /
RUN uv pip install -r /plugin_requirements.txt
