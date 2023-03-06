import { AzureFunction, Context, HttpRequest } from '@azure/functions'
import { ChatGPTAPI } from 'chatgpt'
import { oraPromise } from 'ora'

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
    const clientOptions = {
      // (Optional) Parameters as described in https://platform.openai.com/docs/api-reference/completions
      modelOptions: {
        // The model is set to text-chat-davinci-002-20230126 by default, but you can override
        // it and any other parameters here
        model: 'text-davinci-002-render'
      },
      // (Optional) Set a custom prompt prefix. As per my testing it should work with two newlines
      // promptPrefix: 'You are not ChatGPT...\n\n',
      // (Optional) Set a custom name for the user
      // userLabel: 'User',
      // (Optional) Set a custom name for ChatGPT
      // chatGptLabel: 'ChatGPT',
      // (Optional) Set to true to enable `console.debug()` logging
      debug: false
    }
    const cacheOptions = {
      // Options for the Keyv cache, see https://www.npmjs.com/package/keyv
      // This is used for storing conversations, and supports additional drivers (conversations are stored in memory by default)
      // For example, to use a JSON file (`npm i keyv-file`) as a database:
      // store: new KeyvFile({ filename: 'cache.json' }),
    }
    this.api = new ChatGPTAPI({ apiKey: process.env.OPENAI_API_KEY })
  }

  public async callOpenAI(
    prompt: string,
    messageId: string,
    conversationId: string
  ): Promise<any> {
    console.log('mid:' + messageId)
    console.log('cid:' + conversationId)

    if (messageId == '' || conversationId == '') {
      const res = await oraPromise(this.api.sendMessage(prompt), {
        text: prompt
      })
      return res
    } else {
      const res = await oraPromise(
        this.api.sendMessage(prompt, {
          conversationId: conversationId,
          parentMessageId: messageId
        }),
        {
          text: prompt
        }
      )
      return res
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
    console.log(req.body.prompt)
    const result = await MyOpenAI.Instance()?.callOpenAI(
      req.body.prompt,
      req.body.messageId,
      req.body.conversationId
    )
    context.res = {
      // status: 200, /* Defaults to 200 */
      body: result
    }
  } catch (err) {
    console.log(err)
    context.res = {
      body: err.statusCode + ' ' + err.statusText
    }
  }
}

export default httpTrigger
