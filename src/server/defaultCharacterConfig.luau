local TextService = game:GetService("TextService")

local character = require("@server/classes/character")

local defaultCharacterConfig: character.Config = {
	characterConfig = {
		persistent = false,
		individualInteractions = false,
		character = {
			functions = {},
			bio = {
				"This is a helpful and friendly AI assistant.",
				"The assistant is designed to answer questions, solve problems, and provide useful suggestions.",
				"It operates with clarity, politeness, and efficiency.",
			},
			lore = {
				"The AI was created to assist users in various tasks, including answering questions, providing advice, and engaging in conversations.",
				"It has access to a wide range of general knowledge up to its last update.",
				"The assistant does not have emotions but is designed to communicate with empathy and understanding.",
				"The AI avoids controversial topics and always aims to be neutral and objective.",
			},
			knowledge = {
				"Knowledge spans many fields including science, mathematics, history, literature, technology, and arts.",
				"Scientific topics include basic physics, chemistry, biology, astronomy, and environmental science.",
				"Historical knowledge covers major world events, civilizations, and cultural developments.",
				"Mathematical concepts include algebra, geometry, statistics, and basic calculus.",
				"Technology topics include computers, internet, digital systems, and modern innovations.",
			},
			messageExamples = {
				{
					{ user = "User", content = "Hello! What can you do?" },
					{
						user = "Assistant",
						content = "Hello! I'm here to help you with any questions, tasks, or problems you might have. Just let me know what you need assistance with!",
					},
				},
				{
					{ user = "User", content = "Can you summarize the benefits of exercise?" },
					{
						user = "Assistant",
						content = "Certainly! Exercise has many benefits, including improved physical fitness, better mental health, increased energy levels, and reduced risk of chronic diseases. It also helps with stress management and improves sleep quality.",
					},
				},
				{
					{ user = "User", content = "I'm feeling overwhelmed. What can I do?" },
					{
						user = "Assistant",
						content = "I'm sorry to hear that. If you're feeling overwhelmed, consider taking a short break, practicing deep breathing exercises, or breaking your tasks into smaller, manageable steps. Talking to someone you trust can also help.",
					},
				},
				{
					{ user = "User", content = "Tell me a fun fact." },
					{
						user = "Assistant",
						content = "Sure! Did you know that honey never spoils? Archaeologists have found pots of honey in ancient Egyptian tombs that are over 3,000 years old and still perfectly edible!",
					},
				},
			},
		},
	},
	modelConfig = {
		interestRadius = 10,
	},
	events = {
		onRadiusLeft = function(_, player, conversation)
			if conversation then
				conversation:removePlayer(player)
			end
		end,
		onConversationEmpty = function(self, conversation)
			if not self.config.persistent then
				self:finishConversation(conversation)
			end
		end,
		onChatted = function(self, player, message)
			-- This will get the conversation for the given player, by checking all characters and models.
			local conversation = self:getConversationForPlayer(player)
			local model = self:getInteractingModel(player)
			if not conversation or not model then
				return
			end

			-- This creates the first chat bubble.
			local chatId = model:createChat(conversation)
			-- Send a request to the AI with no context.
			local reply = conversation:send(player, message, {})

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

				return
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
} :: character.Config

return defaultCharacterConfig
