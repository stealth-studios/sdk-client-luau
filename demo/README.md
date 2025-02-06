<div align="center">

# Stealth SDK Luau Example

</div>

This SDK comes with a built-in demo place to test the backend, assuming it is running the basic framework. It consists of a baseplate and a test NPC. Players can interact with this NPC to test the chatbot.

### Setup

1. Clone the repository and navigate to the directory:

```bash
git clone https://github.com/stealth-studios/sdk-client-luau.git
cd sdk-client-luau
```

2. Download packages:

```bash
lune run install-packages
```

3. Create a `env.luau` file with the following variables:

```env
API_URL=<link_to_local_backend>
API_KEY=<api_auth_key>
```

4. Run the development script:

```bash
lune run dev
```

5. Sync your changes into Roblox via Rojo
