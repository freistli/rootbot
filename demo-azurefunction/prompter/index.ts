import { AzureFunction, Context, HttpRequest } from '@azure/functions'
import { ChatGPTAPI } from 'chatgpt'
import { createChatGPTPrompt } from 'chatgpt-prompts'
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
    this.api = new ChatGPTAPI({ apiKey: process.env.OPENAI_API_KEY })
  }

  public async callOpenAI(prompt: string, messageId: string): Promise<any> {
    console.log('mid:' + messageId)

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
  }
}

class Choice {
  public title: string
  public value: string
}
class ClassHelper {
  static getMethodNames(obj) {
    var methodName = null
    var methodArray = new Array()
    Object.getOwnPropertyNames(obj).forEach((prop) => {
      var choice = new Choice()
      choice.title = prop
      choice.value = prop
      methodArray.push(choice)
    })
    methodArray.sort((a: Choice, b: Choice) => {
      if (a.title.toLowerCase() > b.title.toLowerCase()) return 1
      if (a.title.toLowerCase() < b.title.toLowerCase()) return -1
      return 0
    })
    return methodArray
  }
}
const httpTrigger: AzureFunction = async function (
  context: Context,
  req: HttpRequest
): Promise<void> {
  context.log('HTTP trigger function processed a request.')
  const name = req.body && req.body.name
  const message = req.body && req.body.prompt
  const prompt = createChatGPTPrompt(MyOpenAI.Instance().api)

  try {
    if (name == 'getMethodList') {
      context.res = {
        // status: 200, /* Defaults to 200 */
        body: ClassHelper.getMethodNames(prompt)
      }
    } else {
      let result = await prompt[name](message)

      console.log(result.text)
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
