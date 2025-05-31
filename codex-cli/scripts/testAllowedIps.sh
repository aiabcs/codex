#!/bin/bash

#!/bin/bash
next_instance="$HOME/src/codex-tests/firewalltest001"
# create the next instance directory
mkdir -p "$next_instance"

# Initialize OPENAI_ALLOWED_DOMAINS with core domains
export OPENAI_ALLOWED_DOMAINS="api.github.com github.com"

# Add OpenAI and Azure OpenAI endpoints
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS api.openai.com"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS api4c9f86da943f4670bed2f3d40d8847c382yedt9t163bf3zfpiw1h.eastus2.cloudapp.azure.com"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS apif52012fb91654e8c9f8a14aaecaa8c6f44erawvbyh5bf5t2q3xms.northcentralus.cloudapp.azure.com"

# Add Python package repository domains
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS pypi.org"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS a2043.dscr.akamai.net"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS a918.dscr.akamai.net"

# Add Azure Web Apps domains
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS waws-prod-ch1-ca8d2570.sip.p.azurewebsites.windows.net"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS waws-prod-ch1-fbae39a0.sip.p.azurewebsites.windows.net"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS waws-prod-ch1-fa793126.sip.p.azurewebsites.windows.net"

# Add Azure DevOps and management domains
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS dev.azure.com"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS management.core.windows.net"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS chi.next.a.prd.aadg.akadns.net"
#export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS www.tm.v4.a.prd.aadg.trafficmanager.net"

# Add Microsoft and Azure infrastructure domains
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS e11290.dspg.akamaiedge.net"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS www.tm.f.prd.aadg.trafficmanager.net"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS l-0009.l-msedge.net"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS windows.net"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS visualstudio.com"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS microsoft.com"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS live.com"

# Add Visual Studio and Azure assets domains
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS a542.dscd.akamai.net"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS a1430.dscd.akamai.net"
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS e13287.dscg.akamaiedge.net"

# my organization specific domains
export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS l-0009.l-msedge.net" #aiabcs.visualstudio.com"

# # Add Azure and NuGet domains
# export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS azurewebsites.net"
# export OPENAI_ALLOWED_DOMAINS="$OPENAI_ALLOWED_DOMAINS nuget.org"

echo "Testing allowed IPs for domains: $OPENAI_ALLOWED_DOMAINS"
echo ""

echo "To run a FIREWALL test, you can use the following command:"
# for simple .NET 8 MVC app to manage books in a public library
echo "./scripts/run_in_container.sh --work_dir $next_instance \"echo hello world\""

# then do
echo "cd app$next_instance"
echo "python3 -m venv .venv"
echo "chmod +x .venv/bin/activate"
echo ".venv/bin/activate"
echo ".venv/bin/pip3 install -r requirements.txt"

# for .net small console app with restore and build
echo "To run a .NET test, you can use the following command:"
echo "cd app$next_instance"
echo "dotnet new console -n MyConsoleApp"
echo "cd MyConsoleApp"
echo "dotnet add package Microsoft.Extensions.DependencyInjection"
echo "dotnet restore"
echo "dotnet build"

# fetch allowed IPs for github.com api by parsing https://api.github.com/meta
# sample output:
# Allowed IP: 192.30.252.0/22
# Allowed IP: 185.199.108.0/22
# Allowed IP: 140.82.112.0/20
# Allowed IP: 143.55.64.0/20
# Allowed IP: 2a0a:a440::/29
# Allowed IP: 2606:50c0::/32
echo "Fetching allowed IPs for github.com API..."
curl -s https://api.github.com/meta | jq -r '.hooks[]' | while read -r ip; do
    echo "Allowed IP: $ip"
done




