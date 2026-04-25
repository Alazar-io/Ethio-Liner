'use client'

import { useState, useEffect } from 'react'
import {
  AlertTriangle,
  Heart,
  Droplets,
  User,
  ChevronRight,
  CheckCircle2,
  Clock,
  ArrowLeft,
  Phone,
} from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Checkbox } from '@/components/ui/checkbox'
import { emergencyConditions } from '@/lib/mock-data'
import type { EmergencyCondition } from '@/lib/types'

const iconMap: Record<string, React.ReactNode> = {
  Heart: <Heart className="h-8 w-8" />,
  Droplets: <Droplets className="h-8 w-8" />,
  User: <User className="h-8 w-8" />,
}

export function EmergencyPanel() {
  const [selectedCondition, setSelectedCondition] = useState<EmergencyCondition | null>(null)
  const [completedSteps, setCompletedSteps] = useState<Set<number>>(new Set())
  const [elapsedTime, setElapsedTime] = useState(0)

  useEffect(() => {
    let interval: NodeJS.Timeout
    if (selectedCondition) {
      interval = setInterval(() => {
        setElapsedTime((prev) => prev + 1)
      }, 1000)
    }
    return () => clearInterval(interval)
  }, [selectedCondition])

  const handleSelectCondition = (condition: EmergencyCondition) => {
    setSelectedCondition(condition)
    setCompletedSteps(new Set())
    setElapsedTime(0)
  }

  const handleBack = () => {
    setSelectedCondition(null)
    setCompletedSteps(new Set())
    setElapsedTime(0)
  }

  const toggleStep = (index: number) => {
    setCompletedSteps((prev) => {
      const next = new Set(prev)
      if (next.has(index)) {
        next.delete(index)
      } else {
        next.add(index)
      }
      return next
    })
  }

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  const getUrgencyColor = (level: string) => {
    switch (level) {
      case 'critical':
        return 'bg-red-600'
      case 'high':
        return 'bg-amber-500'
      default:
        return 'bg-yellow-500'
    }
  }

  if (selectedCondition) {
    return (
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <Button variant="ghost" onClick={handleBack} className="gap-2">
            <ArrowLeft className="h-4 w-4" />
            Back to Categories
          </Button>
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2 rounded-lg bg-destructive/10 px-4 py-2 text-destructive">
              <Clock className="h-5 w-5" />
              <span className="font-mono text-xl font-bold">{formatTime(elapsedTime)}</span>
            </div>
            <a href="tel:911">
              <Button variant="destructive" className="gap-2">
                <Phone className="h-4 w-4" />
                Call 911
              </Button>
            </a>
          </div>
        </div>

        <Card className="border-destructive/30 bg-destructive/5">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-3">
              <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-destructive/20 text-destructive">
                {iconMap[selectedCondition.icon]}
              </div>
              <div>
                <CardTitle className="text-2xl text-destructive">
                  {selectedCondition.name}
                </CardTitle>
                <Badge variant="destructive" className="mt-1">
                  {selectedCondition.urgencyLevel.toUpperCase()} PRIORITY
                </Badge>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="mb-4 rounded-lg bg-destructive/20 p-3 text-center">
              <p className="text-lg font-bold text-destructive">
                CALL 911 IMMEDIATELY FOR LIFE-THREATENING EMERGENCIES
              </p>
            </div>

            <div className="space-y-3">
              <p className="font-medium text-foreground">Emergency Steps:</p>
              {selectedCondition.steps.map((step, index) => (
                <div
                  key={index}
                  className={`flex cursor-pointer items-start gap-4 rounded-lg border-2 p-4 transition-all ${
                    completedSteps.has(index)
                      ? 'border-emerald-500 bg-emerald-50'
                      : 'border-border bg-card hover:border-primary/30'
                  }`}
                  onClick={() => toggleStep(index)}
                >
                  <Checkbox
                    checked={completedSteps.has(index)}
                    onCheckedChange={() => toggleStep(index)}
                    className="mt-0.5 h-6 w-6"
                  />
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <span
                        className={`flex h-7 w-7 items-center justify-center rounded-full text-sm font-bold ${
                          completedSteps.has(index)
                            ? 'bg-emerald-500 text-white'
                            : 'bg-destructive/20 text-destructive'
                        }`}
                      >
                        {completedSteps.has(index) ? (
                          <CheckCircle2 className="h-4 w-4" />
                        ) : (
                          index + 1
                        )}
                      </span>
                      <p
                        className={`text-lg ${
                          completedSteps.has(index)
                            ? 'text-muted-foreground line-through'
                            : 'font-medium text-foreground'
                        }`}
                      >
                        {step}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            <div className="mt-6 rounded-lg bg-amber-50 p-4">
              <p className="text-sm text-amber-800">
                <strong>Important:</strong> These are general first aid guidelines. Follow
                instructions from emergency services when they arrive. Do not attempt procedures
                you are not trained for.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="rounded-lg border-2 border-destructive/30 bg-destructive/5 p-4">
        <div className="flex items-center gap-3">
          <AlertTriangle className="h-6 w-6 text-destructive" />
          <div>
            <p className="font-semibold text-destructive">Emergency Mode</p>
            <p className="text-sm text-muted-foreground">
              Select a condition for step-by-step first aid guidance. Call 911 for life-threatening
              emergencies.
            </p>
          </div>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        {emergencyConditions.map((condition) => (
          <Card
            key={condition.id}
            className="group cursor-pointer border-2 transition-all hover:-translate-y-1 hover:border-destructive/50 hover:shadow-lg"
            onClick={() => handleSelectCondition(condition)}
          >
            <CardContent className="p-6">
              <div className="mb-4 flex items-center justify-between">
                <div
                  className={`flex h-14 w-14 items-center justify-center rounded-xl ${getUrgencyColor(
                    condition.urgencyLevel
                  )} text-white`}
                >
                  {iconMap[condition.icon]}
                </div>
                <ChevronRight className="h-5 w-5 text-muted-foreground transition-transform group-hover:translate-x-1" />
              </div>
              <h3 className="mb-1 text-xl font-semibold text-foreground">{condition.name}</h3>
              <p className="text-sm text-muted-foreground">
                {condition.steps.length} emergency steps
              </p>
              <Badge
                variant="outline"
                className={`mt-3 ${
                  condition.urgencyLevel === 'critical'
                    ? 'border-red-300 text-red-600'
                    : 'border-amber-300 text-amber-600'
                }`}
              >
                {condition.urgencyLevel.charAt(0).toUpperCase() + condition.urgencyLevel.slice(1)}{' '}
                Priority
              </Badge>
            </CardContent>
          </Card>
        ))}
      </div>

      <Card>
        <CardContent className="p-6">
          <div className="flex items-center gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-destructive text-white">
              <Phone className="h-6 w-6" />
            </div>
            <div className="flex-1">
              <p className="font-semibold text-foreground">Emergency Services</p>
              <p className="text-sm text-muted-foreground">
                For immediate life-threatening emergencies
              </p>
            </div>
            <a href="tel:911">
              <Button variant="destructive" size="lg" className="gap-2">
                <Phone className="h-5 w-5" />
                Call 911
              </Button>
            </a>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
