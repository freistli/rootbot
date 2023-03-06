import dotenv from 'dotenv-safe'
import express from 'express'
import { oraPromise } from 'ora'
import { ChatGPTAPI } from 'chatgpt'

dotenv.config({path: './.env'})

/**
 * Demo CLI for testing basic functionality.
 *
 * ```
 * npx tsx demo-express.ts
 * ```
 */
class requestData {
  public prompt: string = ''
}
class App {
  public express
  public api: any

  constructor() {
    this.express = express()
    this.express.use(express.json())
    this.express.use(express.urlencoded({ extended: true }))
    this.mountRoutes()
    this.initOpenAI()
  }

  private mountRoutes(): void {
    const router = express.Router()
    router.post('/api/openai', async (req: any, res: any) => {
      try {
        console.log(req.body.prompt)
        const result = await this.callOpenAI(
          req.body.prompt,
          req.body.messageId
        )
        res.send(result)
      } catch (err: any) {
        console.log(err)
        res.send(err.statusCode + ' ' + err.statusText)
      }
    })
    this.express.use('/', router)
  }

  public async initOpenAI() {
    
    this.api = new ChatGPTAPI({
      apiKey: process.env.OPENAI_API_KEY
    })
  }

  public async callOpenAI(
    prompt: string,
    messageId: string
  ): Promise<any> {
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

  public async closeOpenAI() {
    // close the browser at the end
    await this.api.closeSession()
  }
}

const port = 7071

const app: express.Application = new App().express
app.listen(port, () => {
  console.log(`server is listening on ${port}`)
})
