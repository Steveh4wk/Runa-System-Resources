-- Mostra versione nei log
SCRIPT_VERSION = GetResourceMetadata(GetCurrentResourceName(), 'version')
print(('Script version %s started'):format(SCRIPT_VERSION))