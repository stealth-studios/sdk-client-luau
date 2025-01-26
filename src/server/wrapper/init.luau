local wrapper = {}

local constants = require("@src/constants")
local sendRequest = require("./sendRequest")

local wrapperData: WrapperData = {} :: WrapperData

local function formatUsers(users: { Player }): { FormattedPlayer }
	local formatted = {}

	for _, player in users do
		table.insert(formatted, {
			id = tostring(player.UserId),
			name = player.DisplayName,
		})
	end

	return formatted
end

local function formatDictionary(dictionary: { [string]: string }): { { key: string, value: string } }
	local formatted = {}

	for key, value in dictionary do
		table.insert(formatted, {
			key = key,
			value = value,
		})
	end

	return formatted
end

-- while this could be seen like a security risk in some cases, it is only on the server;
-- only developers can abuse it, and they could do so regardless
function wrapper.init(data: WrapperData)
	wrapperData = data
end

function wrapper.create(
	config: {
		character: any & { name: string },
		functions: { [string]: Function }?,
	},
	users: { Player }?,
	persistenceToken: string?
): ConversationData?
	local response: Response<ConversationData> = sendRequest(`{wrapperData.url}/api/create`, "POST", {
		persistenceToken = persistenceToken,
		character = config.character,
		users = users and formatUsers(users) or {},
	}, {
		Authorization = wrapperData.auth,
	})

	if not response.success then
		warn(`{constants.ENGINE_LOG_PREFIX} Failed to create conversation: {response.status} {response.message}`)
		return nil
	end

	return response.body
end

function wrapper.send(
	conversation: ConversationData,
	message: string,
	context: { [string]: string }?,
	player: Player
): SendResponse?
	local response: Response<SendResponse> = sendRequest(`{wrapperData.url}/api/send`, "POST", {
		secret = tostring(conversation.secret),
		context = context and formatDictionary(context) or {},
		message = message,
		playerId = tostring(player.UserId),
	}, {
		Authorization = wrapperData.auth,
	})

	if not response.success then
		warn(
			`{constants.ENGINE_LOG_PREFIX} Failed to send message to conversation {conversation.id}: {response.status} {response.message}`
		)
		return nil
	end

	return response.body
end

function wrapper.update(
	conversation: ConversationData,
	users: { Player }?,
	character: (any & { name: string })?
): boolean
	local response: Response<nil> = sendRequest(`{wrapperData.url}/api/update`, "POST", {
		secret = conversation.secret,
		users = users and formatUsers(users) or nil,
		character = character,
	}, {
		Authorization = wrapperData.auth,
	})

	if not response.success then
		warn(
			`{constants.ENGINE_LOG_PREFIX} Failed to update conversation {conversation.id}: {response.status} {response.message}`
		)
	end

	return response.success
end

function wrapper.finish(conversation: ConversationData): boolean
	local response: Response<nil> = sendRequest(`{wrapperData.url}/api/finish`, "POST", {
		secret = conversation.secret,
	}, {
		Authorization = wrapperData.auth,
	})

	if not response.success then
		warn(
			`{constants.ENGINE_LOG_PREFIX} Failed to finish conversation {conversation.id}: {response.status} {response.message}`
		)
	end

	return response.success
end

type Response<T> = sendRequest.Response<T>

type FormattedPlayer = {
	id: string,
	name: string,
}

type ConversationData = {
	id: string,
	secret: string,
}

type SendResponse = {
	flagged: boolean,
	content: string,
	cancelled: boolean?,
	calls: {
		{
			name: string,
			parameters: {
				[string]: number | boolean | string,
			},
		}
	}?,
}

export type Function = {
	description: string?,
	parameters: {
		{
			name: string,
			description: string,
			type: "string" | "number" | "boolean",
		}
	},
	[string]: any,
}

export type WrapperData = {
	auth: Secret | string,
	url: string,
}

return wrapper
