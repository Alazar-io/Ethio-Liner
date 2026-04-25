'use client'

import { useState, useRef, useEffect } from 'react'
import {
  Send,
  Bot,
  User,
  Sparkles,
  Pill,
  AlertTriangle,
  HelpCircle,
  Trash2,
  Brain,
  FileSearch,
  Heart,
  Activity,
  Loader2,
  CheckCircle2,
  ArrowRight,
} from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Badge } from '@/components/ui/badge'
import { useApp } from '@/lib/app-context'
import type { AgentResponse, AgentThought } from '@/lib/types'
import type { Page } from './sidebar-navigation'

const suggestionButtons = [
  { label: 'Explain my medication', icon: Pill, key: 'explain my medication' },
  { label: 'What should I do if I feel sick?', icon: HelpCircle, key: 'what should I do if I feel sick' },
  { label: 'Summarize my health', icon: Activity, key: 'summarize my health' },
]

const tools = [
  { name: 'Patient Profile Tool', icon: User, description: 'Accessing patient data...' },
  { name: 'Prescription Tool', icon: Pill, description: 'Checking medications...' },
  { name: 'Emergency Protocol Tool', icon: AlertTriangle, description: 'Evaluating urgency...' },
  { name: 'Women\'s Health Tool', icon: Heart, description: 'Checking cycle data...' },
]

interface AIHealthAgentProps {
  onNavigateToEmergency?: () => void
}

export function AIHealthAgent({ onNavigateToEmergency }: AIHealthAgentProps) {
  const { chatMessages, addChatMessage, clearChat, user } = useApp()
  const [input, setInput] = useState('')
  const [isProcessing, setIsProcessing] = useState(false)
  const [currentThoughts, setCurrentThoughts] = useState<AgentThought[]>([])
  const [currentResponse, setCurrentResponse] = useState<AgentResponse | null>(null)
  const [toolsBeingUsed, setToolsBeingUsed] = useState<string[]>([])
  const scrollRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight
    }
  }, [chatMessages, currentThoughts])

  const simulateAgentThinking = async (message: string): Promise<AgentResponse> => {
    const thoughts: AgentThought[] = []
    const usedTools: string[] = []
    const lowerMessage = message.toLowerCase()

    // Step 1: Input Analysis
    thoughts.push({
      id: '1',
      type: 'analyzing',
      content: 'Understanding user query...',
    })
    setCurrentThoughts([...thoughts])
    await new Promise((r) => setTimeout(r, 600))

    // Step 2: Tool Selection & Usage
    const toolsToUse: typeof tools[number][] = [tools[0]] // Always use Patient Profile

    if (lowerMessage.includes('medication') || lowerMessage.includes('prescription') || lowerMessage.includes('drug')) {
      toolsToUse.push(tools[1])
    }
    if (lowerMessage.includes('emergency') || lowerMessage.includes('pain') || lowerMessage.includes('chest') || lowerMessage.includes('bleeding') || lowerMessage.includes('faint')) {
      toolsToUse.push(tools[2])
    }
    if (user?.gender === 'Female' && (lowerMessage.includes('period') || lowerMessage.includes('cycle') || lowerMessage.includes('cramp'))) {
      toolsToUse.push(tools[3])
    }

    for (const tool of toolsToUse) {
      usedTools.push(tool.name)
      setToolsBeingUsed([...usedTools])
      thoughts.push({
        id: `tool-${tool.name}`,
        type: 'tool',
        content: tool.description,
        toolName: tool.name,
      })
      setCurrentThoughts([...thoughts])
      await new Promise((r) => setTimeout(r, 500))
    }

    // Step 3: Thinking Process
    const thinkingSteps = [
      'Analyzing symptoms...',
      'Checking patient history...',
      'Evaluating risk level...',
      'Consulting medical protocols...',
    ]

    for (const step of thinkingSteps) {
      thoughts.push({
        id: `think-${step}`,
        type: 'thinking',
        content: step,
      })
      setCurrentThoughts([...thoughts])
      await new Promise((r) => setTimeout(r, 400))
    }

    // Step 4: Generate Structured Response
    let severity: 'Low' | 'Medium' | 'High' = 'Low'
    let reason = ''
    let recommendation = ''
    let emergencyAction: string | undefined

    if (lowerMessage.includes('chest pain') || lowerMessage.includes('can\'t breathe') || lowerMessage.includes('severe bleeding')) {
      severity = 'High'
      reason = 'Symptoms indicate a potentially life-threatening condition requiring immediate attention.'
      recommendation = 'Seek emergency medical care immediately. Call emergency services or go to the nearest emergency room.'
      emergencyAction = 'Call 911 immediately'
    } else if (lowerMessage.includes('fever') || lowerMessage.includes('headache') || lowerMessage.includes('dizzy') || lowerMessage.includes('sick')) {
      severity = 'Medium'
      reason = 'Symptoms suggest a condition that needs monitoring and may require medical consultation.'
      recommendation = 'Rest and stay hydrated. Monitor symptoms for 24-48 hours. If symptoms worsen or persist, consult a healthcare provider.'
    } else if (lowerMessage.includes('medication') || lowerMessage.includes('prescription')) {
      severity = 'Low'
      reason = 'General medication inquiry - no immediate health concern detected.'
      const meds = user?.prescriptions.length 
        ? user.prescriptions.map(p => `${p.drugName} (${p.dosage}, ${p.frequency})`).join(', ')
        : 'No active prescriptions on file'
      recommendation = `Your current medications: ${meds}. Always take medications as prescribed and consult your doctor before making changes.`
    } else if (lowerMessage.includes('health') || lowerMessage.includes('summary')) {
      severity = 'Low'
      reason = 'Health summary request - reviewing patient profile.'
      recommendation = `Health Overview for ${user?.name || 'Patient'}: Age ${user?.age || 'N/A'}, ${user?.condition ? `Condition: ${user.condition}` : 'No conditions on file'}. ${user?.prescriptions.length || 0} active prescription(s). Keep up with regular checkups and maintain a healthy lifestyle.`
    } else {
      severity = 'Low'
      reason = 'General health inquiry with no concerning symptoms detected.'
      recommendation = 'For general health maintenance, ensure adequate sleep, balanced nutrition, regular exercise, and stay hydrated. Schedule regular checkups with your healthcare provider.'
    }

    thoughts.push({
      id: 'complete',
      type: 'complete',
      content: 'Analysis complete',
    })
    setCurrentThoughts([...thoughts])

    return {
      severity,
      reason,
      recommendation,
      emergencyAction,
      thoughts,
      toolsUsed: usedTools,
    }
  }

  const handleSend = async (message: string) => {
    if (!message.trim() || isProcessing) return

    addChatMessage({ role: 'user', content: message })
    setInput('')
    setIsProcessing(true)
    setCurrentThoughts([])
    setCurrentResponse(null)
    setToolsBeingUsed([])

    const response = await simulateAgentThinking(message)
    setCurrentResponse(response)

    // Add assistant response
    const responseText = `**Severity:** ${response.severity}\n\n**Assessment:** ${response.reason}\n\n**Recommendation:** ${response.recommendation}${response.emergencyAction ? `\n\n**Emergency Action:** ${response.emergencyAction}` : ''}`
    addChatMessage({ role: 'assistant', content: responseText })

    setIsProcessing(false)
    setCurrentThoughts([])
    setToolsBeingUsed([])
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    handleSend(input)
  }

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'High':
        return 'bg-destructive text-destructive-foreground'
      case 'Medium':
        return 'bg-amber-500 text-white'
      default:
        return 'bg-emerald-500 text-white'
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-foreground">AI Health Agent</h1>
        <p className="text-muted-foreground">
          Intelligent health analysis with transparent reasoning
        </p>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        {/* Main Chat Area */}
        <Card className="flex h-[600px] flex-col lg:col-span-2">
          <CardHeader className="flex-row items-center justify-between space-y-0 border-b border-border pb-4">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-500/10">
                <Bot className="h-5 w-5 text-emerald-600" />
              </div>
              <div>
                <CardTitle className="text-lg">Health Agent</CardTitle>
                <p className="text-sm text-muted-foreground">
                  {user ? `Assisting ${user.name}` : 'AI-powered health analysis'}
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
              {chatMessages.length === 0 && !isProcessing ? (
                <div className="flex h-full flex-col items-center justify-center gap-6 py-12">
                  <div className="flex h-16 w-16 items-center justify-center rounded-full bg-emerald-500/10">
                    <Brain className="h-8 w-8 text-emerald-600" />
                  </div>
                  <div className="text-center">
                    <h3 className="text-lg font-semibold text-foreground">Health Agent Ready</h3>
                    <p className="mt-1 max-w-sm text-sm text-muted-foreground">
                      I analyze your symptoms using medical protocols and provide structured assessments with severity levels.
                    </p>
                  </div>
                  <div className="flex flex-wrap justify-center gap-2">
                    {suggestionButtons.map((suggestion) => (
                      <Button
                        key={suggestion.key}
                        variant="outline"
                        size="sm"
                        onClick={() => handleSend(suggestion.key)}
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
                          message.role === 'user' ? 'bg-primary text-primary-foreground' : 'bg-emerald-500/10'
                        }`}
                      >
                        {message.role === 'user' ? (
                          <User className="h-4 w-4" />
                        ) : (
                          <Bot className="h-4 w-4 text-emerald-600" />
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
                              {line.startsWith('**') && line.includes(':**') ? (
                                <>
                                  <strong>{line.split(':**')[0].replace(/\*\*/g, '')}:</strong>
                                  {line.split(':**')[1]?.replace(/\*\*/g, '')}
                                </>
                              ) : (
                                line.replace(/\*\*/g, '')
                              )}
                            </p>
                          ))}
                        </div>
                      </div>
                    </div>
                  ))}

                  {/* Show current response card for High severity */}
                  {currentResponse?.severity === 'High' && !isProcessing && (
                    <Card className="border-destructive/50 bg-destructive/5">
                      <CardContent className="p-4">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <AlertTriangle className="h-5 w-5 text-destructive" />
                            <span className="font-semibold text-destructive">Emergency Action Required</span>
                          </div>
                          <Button 
                            size="sm" 
                            variant="destructive"
                            onClick={onNavigateToEmergency}
                            className="gap-2"
                          >
                            Go to Emergency Help
                            <ArrowRight className="h-4 w-4" />
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  )}
                </div>
              )}
            </ScrollArea>

            <div className="border-t border-border p-4">
              {chatMessages.length > 0 && !isProcessing && (
                <div className="mb-3 flex flex-wrap gap-2">
                  {suggestionButtons.map((suggestion) => (
                    <Button
                      key={suggestion.key}
                      variant="outline"
                      size="sm"
                      onClick={() => handleSend(suggestion.key)}
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
                  placeholder="Describe your symptoms or ask a health question..."
                  disabled={isProcessing}
                  className="flex-1"
                />
                <Button type="submit" disabled={!input.trim() || isProcessing}>
                  <Send className="h-4 w-4" />
                  <span className="sr-only">Send message</span>
                </Button>
              </form>
            </div>
          </CardContent>
        </Card>

        {/* Agent Reasoning Panel */}
        <div className="space-y-4">
          {/* Tool Usage Log */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="flex items-center gap-2 text-base">
                <FileSearch className="h-4 w-4 text-primary" />
                Tool Usage Log
              </CardTitle>
            </CardHeader>
            <CardContent>
              {toolsBeingUsed.length === 0 && !isProcessing ? (
                <p className="text-sm text-muted-foreground">
                  Tools will appear here when processing queries
                </p>
              ) : (
                <div className="space-y-2">
                  {tools.map((tool) => {
                    const isUsed = toolsBeingUsed.includes(tool.name)
                    const isActive = isProcessing && toolsBeingUsed[toolsBeingUsed.length - 1] === tool.name

                    return (
                      <div
                        key={tool.name}
                        className={`flex items-center gap-3 rounded-lg border p-2 transition-all ${
                          isUsed 
                            ? isActive 
                              ? 'border-primary bg-primary/5' 
                              : 'border-emerald-500/50 bg-emerald-500/5'
                            : 'border-border opacity-40'
                        }`}
                      >
                        <div className={`rounded-md p-1.5 ${isUsed ? 'bg-primary/10' : 'bg-muted'}`}>
                          <tool.icon className={`h-4 w-4 ${isUsed ? 'text-primary' : 'text-muted-foreground'}`} />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium truncate">{tool.name}</p>
                        </div>
                        {isUsed && (
                          isActive ? (
                            <Loader2 className="h-4 w-4 animate-spin text-primary" />
                          ) : (
                            <CheckCircle2 className="h-4 w-4 text-emerald-500" />
                          )
                        )}
                      </div>
                    )
                  })}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Thinking Panel */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="flex items-center gap-2 text-base">
                <Brain className="h-4 w-4 text-primary" />
                Agent Thinking
              </CardTitle>
            </CardHeader>
            <CardContent>
              {currentThoughts.length === 0 ? (
                <p className="text-sm text-muted-foreground">
                  Reasoning steps will appear here
                </p>
              ) : (
                <div className="space-y-2">
                  {currentThoughts.filter(t => t.type === 'thinking' || t.type === 'analyzing' || t.type === 'complete').map((thought) => (
                    <div
                      key={thought.id}
                      className="flex items-center gap-2 text-sm"
                    >
                      {thought.type === 'complete' ? (
                        <CheckCircle2 className="h-4 w-4 text-emerald-500" />
                      ) : (
                        <Loader2 className={`h-4 w-4 text-primary ${isProcessing ? 'animate-spin' : ''}`} />
                      )}
                      <span className={thought.type === 'complete' ? 'text-emerald-600 font-medium' : 'text-muted-foreground'}>
                        {thought.content}
                      </span>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Decision Card */}
          {currentResponse && !isProcessing && (
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="flex items-center gap-2 text-base">
                  <Sparkles className="h-4 w-4 text-primary" />
                  Final Decision
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">Severity</span>
                  <Badge className={getSeverityColor(currentResponse.severity)}>
                    {currentResponse.severity}
                  </Badge>
                </div>
                <div>
                  <p className="text-xs font-medium text-muted-foreground mb-1">Assessment</p>
                  <p className="text-sm text-foreground">{currentResponse.reason}</p>
                </div>
                {currentResponse.emergencyAction && (
                  <div className="rounded-lg bg-destructive/10 p-3">
                    <p className="text-sm font-medium text-destructive">
                      {currentResponse.emergencyAction}
                    </p>
                  </div>
                )}
              </CardContent>
            </Card>
          )}
        </div>
      </div>

      <p className="text-center text-xs text-muted-foreground">
        This AI agent is for informational purposes only and does not replace professional medical advice.
      </p>
    </div>
  )
}
