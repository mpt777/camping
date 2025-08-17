extends Node

#Multiplayer
signal HostMultiplayer()
signal ConnectMultiplayer(host : String)

signal AddPlayer(id)
signal RemovePlayer(id)

##
signal PlayerLoaded(id : int, player_data: PlayerData)

signal AddMessage(m_message: Message)
signal AddMessageToBox(m_message: Message)

signal AddProjectile(node)

#signal AddGlobalPlayerAuthority()

#signal UILock(locked: bool)
signal SetInputMode(inputs : Array, active: bool)

# UI?
signal StartGame(peer : ENetMultiplayerPeer)
signal ChangeScene(scene : PackedScene)
