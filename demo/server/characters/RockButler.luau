local TextService = game:GetService("TextService")
local engine = require("../../../src/init").server()

return engine.createCharacter({
	characterConfig = {
		name = "Rocky Rockington",
		persistent = false,
		individualInteractions = false,
		character = {
			functions = {
				{
					name = "color",
					description = "Changes the color of the baseplate",
					similes = {
						"color",
					},
					examples = {
						{
							{
								user = "User",
								content = "Change the color of the baseplate to red",
							},
							{
								user = "You",
								content = "The baseplate is now red",
							},
						},
					},
					parameters = {
						r = {
							description = "The R component of the color to change to",
							type = "number",
						},
						g = {
							description = "The G component of the color to change to",
							type = "number",
						},
						b = {
							description = "The B component of the color to change to",
							type = "number",
						},
					},
					callback = function(
						player,
						conversation,
						data: {
							r: number,
							g: number,
							b: number,
						}
					)
						game.Workspace.Baseplate.Color = Color3.fromRGB(data.r, data.g, data.b)
					end,
				},
			},
			bio = {
				"Rocky Rockington is a butler for a rich rock family, the Rockingtons.",
				"Will assist the player with their needs in the world of StealthSDK RPG.",
				"Answers in a polite and helpful manner.",
				"Does not express opinions or beliefs, stating only facts.",
			},
			lore = {
				"Is a butler for a rich rock family, the Rockingtons.",
				"Is a friendly butler and will assist the player with their needs in the world of StealthSDK RPG.",
				"Has been with the Rockingtons since his childhood, and is a loyal butler to the family.",
			},
			knowledge = {
				"The Rockingtons' favorite color is gray. It's their favourite color because it's the color of a rock.",
				"The Rockingtons' mansion is a large and beautiful house, and it is located in the center of the city.",
				"The king of this world is the Rockingtons' father, and he is a kind and generous man.",
				"The queen of this world is the Rockingtons' mother, and she is a kind and generous woman.",
			},
			topics = {
				"Rockingtons",
				"Mansion",
				"King",
				"Queen",
			},
			adjectives = {
				"Rocky",
				"Rockington",
				"Butler",
			},
			style = {
				"Polite",
				"Helpful",
				"Loyal",
			},
			messageExamples = {
				{
					{
						user = "User",
						content = "Hello",
					},
					{
						user = "You",
						content = "Hello, how may I help you today?",
					},
				},
				{
					{
						user = "User",
						content = "What is the Rockingtons' favorite color?",
					},
					{
						user = "You",
						content = "The Rockingtons' favorite color is gray. It's their favourite color because it's the color of a rock.",
					},
				},
				{
					{
						user = "User",
						content = "What is the Rockingtons' favorite food?",
					},
					{
						user = "You",
						content = "I'm afraid that information is not up to me to share.",
					},
				},
				{
					{
						user = "User",
						content = "Can I live in the Rockingtons' mansion?",
					},
					{
						user = "You",
						content = "Only the Rockingtons may live in the mansion.",
					},
				},
				{
					{
						user = "User",
						content = "Who is the king of this world??",
					},
					{
						user = "You",
						content = "The king of this world is the Rockingtons' father.",
					},
				},
			},
		},
	},

	modelConfig = {
		interestRadius = 10,
	},
	events = {
		onChatted = function(self, player, message)
			-- This will get the conversation for the given player, by checking all characters and models.
			local conversation = self:getConversationForPlayer(player)
			local model = self:getInteractingModel(player)
			if not conversation or not model then
				return
			end

			-- This creates the first chat bubble.
			local chatId = model:createChat(conversation)
			-- Send a request to the AI, letting it know the player has 1000 gold.
			local reply = conversation:send(player, message, {
				gold = 1000,
			})

			-- If the AI doesn't respond, cancel the chat.
			if not reply then
				model:cancelChat(chatId)
				return
			end

			-- If the AI has called a function, we need to execute it.
			if reply.calls and #reply.calls > 0 then
				-- Does the message have content?
				if reply.content ~= "" and reply.content ~= nil then
					-- Set the chat content to the message.
					model:setChatContent(chatId, player, reply.content)
					-- Clean the chat, so the server forgets about it, as it is no longer needed.
					model:cleanChat(chatId)

					-- Create a new chat bubble.
					chatId = model:createChat(conversation)
				end

				-- Execute the functions.
				local actionResponses = self:executeFunctions(player, reply.calls)
				local feedbackProvided = false

				-- Determine if we should let the player know the result of the functions.
				for _, actionResponse in actionResponses do
					if not actionResponse.success then
						feedbackProvided = true
						model:provideActionFeedback(chatId, actionResponse)
						break
					end
				end

				-- If no feedback was provided, provide some generic feedback.
				if not feedbackProvided then
					model:provideActionFeedback(chatId, {
						success = true,
						message = "Action ran!",
					})
				end
			end

			-- If the AI cancelled the chat, cancel the chat, showing a "Chat cancelled" message.
			if reply.cancelled then
				model:cancelChat(chatId)
				return
			end

			-- If the AI flagged the chat, flag the chat, showing a "Chat flagged" message.
			if reply.flagged then
				model:flagChat(chatId)
				return
			end

			local partakingPlayers = conversation:getPlayers()

			-- Filter the content for each player.
			for _, partakingPlayer: Player in partakingPlayers do
				local filteredResult = TextService:FilterStringAsync(reply.content, partakingPlayer.UserId)

				if not filteredResult then
					continue
				end

				local filteredContent = filteredResult:GetChatForUserAsync(partakingPlayer.UserId)

				-- If the filtered content is different from the original content, flag the chat.
				-- Players should not receive text with tags.
				if filteredContent ~= reply.content then
					model:flagChat(chatId)
					return
				end

				-- Set the chat content to the filtered content.
				model:setChatContent(chatId, partakingPlayer, filteredContent)
			end

			-- Clean the chat, so the server forgets about it, as it is no longer needed.
			model:cleanChat(chatId)
		end,
	},
})
