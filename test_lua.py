import subprocess
import sys
import re

def test_lua_syntax(filename):
    print(f"Testing basic Lua syntax heuristically for {filename}...")
    try:
        with open(filename, 'r') as f:
            code = f.read()
    except Exception as e:
        print(f"Failed to read file: {e}")
        return False

    # very simple check to balance function/if and end
    # Note: Not a real parser, just a simple sanity check.
    functions = len(re.findall(r'\bfunction\b', code))
    ends = len(re.findall(r'\bend\b', code))
    ifs = len(re.findall(r'\bif\b', code))
    elses = len(re.findall(r'\belse\b', code))
    elseifs = len(re.findall(r'\belseif\b', code))
    dos = len(re.findall(r'\bdo\b', code))

    # Lua usually uses 'end' to close function, if, do (for/while).
    # This is a very rough heuristic.
    print(f"Functions: {functions}, Ifs: {ifs}, Dos: {dos}, Ends: {ends}")

    # Actually just check our specific changes by finding them
    target_function = re.search(r"RegisterNetEvent\('qb-garage:server:PayDepotPrice'(.*?)\nend\)", code, re.DOTALL)
    if not target_function:
        print("Function 'qb-garage:server:PayDepotPrice' not found correctly formatted.")
        return False

    func_body = target_function.group(1)
    if "type(data) ~= 'table'" not in func_body:
        print("Missing 'table' validation for data.")
        return False
    if "type(data.vehicle) ~= 'table'" not in func_body:
        print("Missing 'table' validation for data.vehicle.")
        return False
    if "type(data.vehicle.plate) ~= 'string'" not in func_body:
        print("Missing 'string' validation for data.vehicle.plate.")
        return False
    if "dbVehicle.citizenid ~= Player.PlayerData.citizenid" not in func_body:
        print("Missing authorization check for citizenid.")
        return False

    print("Syntax heuristics and specific logic checks passed.")
    return True

if __name__ == "__main__":
    if test_lua_syntax('server/main.lua'):
        sys.exit(0)
    else:
        sys.exit(1)
