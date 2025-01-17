<div align="center">

# 🎮 sdk-client-luau

_A client for the Stealth SDK, for Roblox!_

[![CI Status](https://github.com/stealth-studios/sdk-client-luau/actions/workflows/ci-luau.yaml/badge.svg)](https://github.com/stealth-studios/sdk-client-luau/actions/workflows/ci-luau.yaml)
[![License](https://img.shields.io/github/license/stealth-studios/sdk-client-luau)](https://github.com/stealth-studios/sdk-client-luau/blob/main/LICENSE)

</div>

## 🛠️ Development

This SDK comes with a built-in demo place to test the backend. It consists of a baseplate and a test NPC. Players can interact with this NPC to test the chatbot. It is non-persistent and allows group interactions.

This SDK comes bundled with a default character config, which implements default behaviour for the chatbot. These values can all be overridden in the character config, implementing custom behaviour when a player leaves the model's radius, enters the model's radius, sends a message, or more. This character config can be viewed [here](./src/server/defaultCharacterConfig.luau).

### Development

1. Download packages:

```bash
lune run install-packages
```

2. Create a `env.luau` file with the following variables:

```env
API_URL=
API_KEY=
```

3. Run the development script:

```bash
lune run dev
```

## 📖 Documentation

You may view the documentation for this library [here](https://google.com/docs/client/luau)!

## 🤝 Contributing

We love your input! We want to make contributing as easy and transparent as possible. Here's how you can help:

- 📖 Review our code guidelines
- 🔍 Check existing issues or create a new one
- 🚀 Submit a pull request with your improvements

### Found a Bug? Have a Suggestion?

We'd love to hear from you! [Open an issue](https://github.com/stealth-studios/sdk-client-luau/issues/new) and help us make this even better.
