import { AzureFunction, Context, HttpRequest } from '@azure/functions'
import {
  AzureChatGPTAPI,
  AzureRedisAdapter,
  ChatMessage
} from '@freistli/azurechatgptapi'
import Keyv from 'keyv'
import { oraPromise } from 'ora'

//dotenv.config()

class MyOpenAI {
  static current: MyOpenAI
  public api: any = null
  private azureRedisStore: Keyv<ChatMessage, any>

  constructor() {
    this.initOpenAI()
  }

  public static Instance() {
    if (MyOpenAI.current != null) return MyOpenAI.current
    else {
      try {
        MyOpenAI.current = new MyOpenAI()
      } catch (err) {
        console.log(err)
        MyOpenAI.current = null
      }
      return MyOpenAI.current
    }
  }

  public async initOpenAI() {
    if (process.env.USE_CACHE?.toLowerCase() === 'azureredis') {
      // Environment variables for cache
      const cacheHostName = process.env.AZURE_CACHE_FOR_REDIS_HOST_NAME
      const cachePassword = process.env.AZURE_CACHE_FOR_REDIS_ACCESS_KEY

      if (!cacheHostName)
        throw Error('AZURE_CACHE_FOR_REDIS_HOST_NAME is empty')
      if (!cachePassword)
        throw Error('AZURE_CACHE_FOR_REDIS_ACCESS_KEY is empty')

      const azureRedisAdapter = new AzureRedisAdapter({
        cacheHostName: process.env.AZURE_CACHE_FOR_REDIS_HOST_NAME,
        cachePassword: process.env.AZURE_CACHE_FOR_REDIS_ACCESS_KEY
      })

      await azureRedisAdapter.connect()

      this.azureRedisStore = new Keyv<ChatMessage, any>({
        store: azureRedisAdapter
      })
    }

    console.log('Initializing ChatGPTAPI instanace')
    this.api = new AzureChatGPTAPI(
      {
        apiKey: process.env.AZURE_OPENAI_API_KEY,
        apiBaseUrl: process.env.AZURE_OPENAI_API_BASE,
        messageStore: this.azureRedisStore,
        debug: false
      },
      process.env.CHATGPT_DEPLOY_NAME ?? 'chatgpt'
    )
    console.log('ChatGPTAPI instanace is created')
  }

  public async callOpenAI(prompt: string, messageId: string): Promise<any> {
    console.log('mid:' + messageId)

    while (this.api === null) {
      await new Promise((resolve) => setTimeout(resolve, 500))
    }

    try {
      if (messageId == '') {
        const res = await oraPromise(this.api.sendMessage(prompt), {
          text: prompt
        })
        return res
      } else {
        const res = await oraPromise(
          this.api.sendMessage(prompt, {
            parentMessageId: messageId
          }),
          {
            text: prompt
          }
        )
        return res
      }
    } catch (e: any) {
      console.log('Failed to handle: ' + prompt + 'with error: ' + e)
      return 'Cannot handle this prompt for the moment, please try again'
    }
  }
}
const httpTrigger: AzureFunction = async function (
  context: Context,
  req: HttpRequest
): Promise<void> {
  context.log('HTTP trigger function processed a request.')
  const name = req.query.name || (req.body && req.body.name)

  try {
    console.log(req.body)

    if (req.body.prompt == undefined || req.body.prompt == '') {
      context.res = {
        // status: 200, /* Defaults to 200 */
        body: 'Prompt contains invalid characters, please try again'
      }
    } else {
      const result = await MyOpenAI.Instance()?.callOpenAI(
        req.body.prompt,
        req.body.messageId
      )

      console.log(req.body)

      context.res = {
        // status: 200, /* Defaults to 200 */
        body: result
      }
    }
  } catch (err) {
    console.log(err)
    context.res = {
      body: err.statusCode + ' ' + err.statusText
    }
  }
}

export default httpTrigger
