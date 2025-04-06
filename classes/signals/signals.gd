extends Node

signal PlayerLoaded(id : int, player_data: PlayerData)

signal AddMessage(m_message: Message)
signal AddMessageToBox(m_message: Message)

signal AddProjectile(node)

#signal AddGlobalPlayerAuthority()

signal UILock(locked: bool)
