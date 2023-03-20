import { AzureFunction, Context, HttpRequest } from '@azure/functions'
import { AzureChatGPTAPI } from '@freistli/azurechatgptapi'
import dotenv from 'dotenv-safe'
import { oraPromise } from 'ora'

//dotenv.config()

class MyOpenAI {
  static current: MyOpenAI
  public api: any

  constructor() {
    this.initOpenAI().then(() => {
      return
    })
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
    this.api = new AzureChatGPTAPI(
      {
        apiKey: process.env.AZURE_OPENAI_API_KEY,
        apiBaseUrl: process.env.AZURE_OPENAI_API_BASE,
        debug: false
      },
      'chatgpt'
    )
  }

  public async callOpenAI(prompt: string, messageId: string): Promise<any> {
    console.log('mid:' + messageId)

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
      console.log('Failed to handle: ' + prompt)
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
