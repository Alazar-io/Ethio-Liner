'use client'

import { useState, useRef, useEffect } from 'react'
import { Send, Bot, User, Sparkles, Pill, AlertTriangle, HelpCircle, Trash2 } from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { ScrollArea } from '@/components/ui/scroll-area'
import { useApp } from '@/lib/app-context'
import { mockAIResponses } from '@/lib/mock-data'

const suggestionButtons = [
  { label: 'Explain my medication', icon: Pill, key: 'explain my medication' },
  { label: 'Emergency help', icon: AlertTriangle, key: 'emergency help' },
  { label: 'Dosage info', icon: HelpCircle, key: 'dosage info' },
]

export function ChatInterface() {
  const { chatMessages, addChatMessage, clearChat, selectedPatient } = useApp()
  const [input, setInput] = useState('')
  const [isTyping, setIsTyping] = useState(false)
  const scrollRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight
    }
  }, [chatMessages])

  const handleSend = async (message: string) => {
    if (!message.trim()) return

    addChatMessage({ role: 'user', content: message })
    setInput('')
    setIsTyping(true)

    // Simulate AI response delay
    await new Promise((resolve) => setTimeout(resolve, 1000 + Math.random() * 1000))

    const lowerMessage = message.toLowerCase()
    let response = mockAIResponses.default

    for (const [key, value] of Object.entries(mockAIResponses)) {
      if (lowerMessage.includes(key)) {
        response = value
        break
      }
    }

    // Personalize response with patient context
    if (selectedPatient) {
      response = response.replace(
        'your condition',
        selectedPatient.condition.toLowerCase()
      )
    }

    addChatMessage({ role: 'assistant', content: response })
    setIsTyping(false)
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    handleSend(input)
  }

  const handleSuggestionClick = (key: string) => {
    handleSend(key)
  }

  return (
    <Card className="flex h-[600px] flex-col">
      <CardHeader className="flex-row items-center justify-between space-y-0 border-b border-border pb-4">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/10">
            <Bot className="h-5 w-5 text-primary" />
          </div>
          <div>
            <CardTitle className="text-lg">Health Assistant</CardTitle>
            <p className="text-sm text-muted-foreground">
              {selectedPatient ? `Assisting ${selectedPatient.name}` : 'AI-powered health guidance'}
            </p>
          </div>
        </div>
        {chatMessages.length > 0 && (
          <Button variant="ghost" size="sm" onClick={clearChat} className="gap-2 text-muted-foreground">
            <Trash2 className="h-4 w-4" />
            Clear
          </Button>
        )}
      </CardHeader>

      <CardContent className="flex flex-1 flex-col p-0">
        <ScrollArea className="flex-1 p-4" ref={scrollRef}>
          {chatMessages.length === 0 ? (
            <div className="flex h-full flex-col items-center justify-center gap-6 py-12">
              <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
                <Sparkles className="h-8 w-8 text-primary" />
              </div>
              <div className="text-center">
                <h3 className="text-lg font-semibold text-foreground">How can I help you today?</h3>
                <p className="mt-1 text-sm text-muted-foreground">
                  Ask me about your medications, health conditions, or emergency guidance.
                </p>
              </div>
              <div className="flex flex-wrap justify-center gap-2">
                {suggestionButtons.map((suggestion) => (
                  <Button
                    key={suggestion.key}
                    variant="outline"
                    size="sm"
                    onClick={() => handleSuggestionClick(suggestion.key)}
                    className="gap-2"
                  >
                    <suggestion.icon className="h-4 w-4" />
                    {suggestion.label}
                  </Button>
                ))}
              </div>
            </div>
          ) : (
            <div className="space-y-4">
              {chatMessages.map((message) => (
                <div
                  key={message.id}
                  className={`flex gap-3 ${message.role === 'user' ? 'flex-row-reverse' : ''}`}
                >
                  <div
                    className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-full ${
                      message.role === 'user' ? 'bg-primary text-primary-foreground' : 'bg-muted'
                    }`}
                  >
                    {message.role === 'user' ? (
                      <User className="h-4 w-4" />
                    ) : (
                      <Bot className="h-4 w-4" />
                    )}
                  </div>
                  <div
                    className={`max-w-[80%] rounded-2xl px-4 py-3 ${
                      message.role === 'user'
                        ? 'bg-primary text-primary-foreground'
                        : 'bg-muted text-foreground'
                    }`}
                  >
                    <div className="whitespace-pre-wrap text-sm leading-relaxed">
                      {message.content.split('\n').map((line, i) => (
                        <p key={i} className={i > 0 ? 'mt-2' : ''}>
                          {line.startsWith('**') && line.endsWith('**') ? (
                            <strong>{line.slice(2, -2)}</strong>
                          ) : line.startsWith('**') ? (
                            <strong>{line.replace(/\*\*/g, '')}</strong>
                          ) : (
                            line
                          )}
                        </p>
                      ))}
                    </div>
                    <p
                      className={`mt-1 text-xs ${
                        message.role === 'user' ? 'text-primary-foreground/70' : 'text-muted-foreground'
                      }`}
                    >
                      {message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </p>
                  </div>
                </div>
              ))}

              {isTyping && (
                <div className="flex gap-3">
                  <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-muted">
                    <Bot className="h-4 w-4" />
                  </div>
                  <div className="rounded-2xl bg-muted px-4 py-3">
                    <div className="flex gap-1">
                      <span className="h-2 w-2 animate-bounce rounded-full bg-muted-foreground/50 [animation-delay:0ms]" />
                      <span className="h-2 w-2 animate-bounce rounded-full bg-muted-foreground/50 [animation-delay:150ms]" />
                      <span className="h-2 w-2 animate-bounce rounded-full bg-muted-foreground/50 [animation-delay:300ms]" />
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}
        </ScrollArea>

        <div className="border-t border-border p-4">
          {chatMessages.length > 0 && (
            <div className="mb-3 flex flex-wrap gap-2">
              {suggestionButtons.map((suggestion) => (
                <Button
                  key={suggestion.key}
                  variant="outline"
                  size="sm"
                  onClick={() => handleSuggestionClick(suggestion.key)}
                  className="gap-1.5 text-xs"
                >
                  <suggestion.icon className="h-3 w-3" />
                  {suggestion.label}
                </Button>
              ))}
            </div>
          )}
          <form onSubmit={handleSubmit} className="flex gap-2">
            <Input
              ref={inputRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Type your health question..."
              disabled={isTyping}
              className="flex-1"
            />
            <Button type="submit" disabled={!input.trim() || isTyping}>
              <Send className="h-4 w-4" />
              <span className="sr-only">Send message</span>
            </Button>
          </form>
          <p className="mt-2 text-center text-xs text-muted-foreground">
            This is an AI assistant for general guidance only. Consult a healthcare provider for medical advice.
          </p>
        </div>
      </CardContent>
    </Card>
  )
}
