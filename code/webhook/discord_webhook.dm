/* Demonstrates using a Discord Webhook to forward chat messages from your game to a Discord text channel.

	Discord's Intro to Webhooks:
		https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks

	Discord's dev docs for webhooks:
		https://discordapp.com/developers/docs/resources/webhook

	* Discord rate-limits webhooks, so messages will fail to send if used too frequently.
		This can be worked around; you can modify HttpPost to get the response which includes
		rate limit info when it occurs. But I won't be doing that here.

		Rate limits doc:
			https://discordapp.com/developers/docs/topics/rate-limits
*/

client
	verb
		// Basic chat command, but with an added webhook.
		say(text as message)
			set category = null
			world << "<b>[src]</b>: [html_encode(text)]"

			// Send the message to the Discord webhook.
			HttpPost(
				/* Replace this with the webhook URL that you can Copy in Discord's Edit Webhook panel.
					It's best to use a global const for this and keep it secret so others can't use it.
				*/
				"https://discord.com/api/webhooks/1337600028306309242/NPZ_Py3E_d2rI17i7fbL0VHtvvjN4OZPqlRGymMtbflaEh9u11sHX-WqPNVf_LYbXNAf",

				/*
				[content] is required and can't be blank.
					It's the message posted by the webhook.

				[avatar_url] and [username] are optional.
					They're taken from your key.
					They override the webhook's name and avatar for the post.
				*/
				list(
					content = text
				)
			)
