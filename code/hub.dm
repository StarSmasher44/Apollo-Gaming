/world
/* This is for any host that would like their server to appear on the main SS13 hub.
 * uncomment the define below to enable the HUB entry for your server
 */
 // We would like to request that the source is only used for testing and not hosting for an audience, if you'd like to play this code, please do so on our official server.
#define HUB_ENABLED 1
	hub = "Exadv1.spacestation13"
	name = "Apollo Gaming"
#ifdef HUB_ENABLED
	hub_password = "kMZy3U5jJHSiBQjr"
#else
	hub_password = "SORRYNOPASSWORD"
#endif