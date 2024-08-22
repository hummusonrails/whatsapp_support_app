# Real-Time WhatsApp Support Chat Application with Couchbase and Vonage

![Couchbase Capella](https://img.shields.io/badge/Couchbase_Capella-Enabled-red)
![Vonage Messages API](https://img.shields.io/badge/Vonage_Messages_API-Enabled-blue)
[![License: MIT](https://cdn.prod.website-files.com/5e0f1144930a8bc8aace526c/65dd9eb5aaca434fac4f1c34_License-MIT-blue.svg)](/LICENSE)
![Static Badge](https://img.shields.io/badge/Code_of_Conduct-Contributor_Covenant-violet.svg)

This is a real-time support WhatsApp chat application built with Couchbase and Vonage. The application allows users to ask support questions of support agents in real time using WhatsApp. Agents are then given suggested answers using Couchbase vector search from the database of previous support tickets to provide support to the current user.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [Usage](#usage)
- [License](#license)

## Features
- Real-time messaging using the Vonage Messages API
- Support for multiple users and agents
- Messages stored in [Couchbase Capella](https://cloud.couchbase.com/)
- Vector search for relevant support ticket information from the Couchbase database
- Simple, elegant UI with Tailwind CSS

## Installation
1. **Clone the Repository**
   ```bash
   git clone https://github.com/hummusonrails/whatsapp_support_app.git
   cd whatsapp_support_app
    ```

2. **Install Dependencies**
   ```bash
    bundle install
   ```

3. **Set Environment Variables**
    Copy the `.env.example` file in the root of the project to `.env` and set the required environment variables.
    ```bash
    VONAGE_API_KEY=your_vonage_api_key
    VONAGE_API_SECRET=your_vonage_api_secret
    COUCHBASE_CONNECTION_STRING=your_couchbase_connection_string
    COUCHBASE_BUCKET=your_couchbase_bucket
    COUCHBASE_USERNAME=your_couchbase_username
    COUCHBASE_PASSWORD=your_couchbase_password
    OPENAI_API_KEY=your_openai_api_key
    ```

## Running the Application

1. Start the Rails Dev Server
    ```bash
    bundle exec bin/dev
    ```

2. Start the [ngrok](https://ngrok.com/) tunnel in a separate terminal window (used to send and receive messages from WhatsApp and Vonage webhook updates)
    ```bash
    ngrok http 3000
    ```

## Usage

Open your browser and navigate to http://localhost:3000. You should see the application's home page. As support queries come in from WhatsApp, they will populate the table on the home page. Agents can then click on a query to view suggested answers from the Couchbase database and interact with the user in real time. Once the query has been answered, the agent can mark it as resolved and the answer will be saved in the database for future reference and to supply future queries with suggested answers.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

