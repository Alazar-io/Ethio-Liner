'use client'

import { useState, useMemo } from 'react'
import { Calendar, Heart, Info, ChevronLeft, ChevronRight } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

interface CycleTrackerProps {
  lastPeriodDate: string
  cycleLength: number
}

interface CyclePhase {
  name: string
  description: string
  tips: string[]
  color: string
  bgColor: string
}

const cyclePhases: Record<string, CyclePhase> = {
  menstrual: {
    name: 'Menstrual Phase',
    description: 'Your period has begun. Focus on rest and self-care.',
    tips: [
      'Stay hydrated and drink warm beverages',
      'Light exercise like walking or yoga can help',
      'Use heat pads for cramp relief',
      'Get plenty of rest',
    ],
    color: 'text-rose-600',
    bgColor: 'bg-rose-50',
  },
  follicular: {
    name: 'Follicular Phase',
    description: 'Energy levels are rising. Great time for new projects.',
    tips: [
      'Increase workout intensity gradually',
      'Good time to start new habits or projects',
      'Focus on iron-rich foods',
      'Energy levels will increase',
    ],
    color: 'text-amber-600',
    bgColor: 'bg-amber-50',
  },
  ovulation: {
    name: 'Ovulation Phase',
    description: 'Peak fertility window. Highest energy levels.',
    tips: [
      'Best time for high-intensity workouts',
      'Social energy is at its peak',
      'Monitor any mid-cycle symptoms',
      'Stay aware of fertility if relevant',
    ],
    color: 'text-emerald-600',
    bgColor: 'bg-emerald-50',
  },
  luteal: {
    name: 'Luteal Phase',
    description: 'Prepare for your next cycle. Focus on relaxation.',
    tips: [
      'Reduce caffeine intake if experiencing PMS',
      'Focus on complex carbs and protein',
      'Gentle exercise recommended',
      'Practice stress management',
    ],
    color: 'text-blue-600',
    bgColor: 'bg-blue-50',
  },
}

export function CycleTracker({ lastPeriodDate, cycleLength: initialCycleLength }: CycleTrackerProps) {
  const [periodDate, setPeriodDate] = useState(lastPeriodDate)
  const [cycleLength, setCycleLength] = useState(initialCycleLength)
  const [viewMonth, setViewMonth] = useState(new Date())

  const cycleInfo = useMemo(() => {
    const lastPeriod = new Date(periodDate)
    const today = new Date()
    const daysSinceLastPeriod = Math.floor(
      (today.getTime() - lastPeriod.getTime()) / (1000 * 60 * 60 * 24)
    )
    const cycleDay = (daysSinceLastPeriod % cycleLength) + 1
    const nextPeriod = new Date(lastPeriod)
    nextPeriod.setDate(nextPeriod.getDate() + cycleLength * Math.ceil(daysSinceLastPeriod / cycleLength))

    let phase: string
    if (cycleDay <= 5) {
      phase = 'menstrual'
    } else if (cycleDay <= 13) {
      phase = 'follicular'
    } else if (cycleDay <= 16) {
      phase = 'ovulation'
    } else {
      phase = 'luteal'
    }

    return {
      cycleDay,
      phase,
      nextPeriod,
      daysUntilNextPeriod: Math.floor(
        (nextPeriod.getTime() - today.getTime()) / (1000 * 60 * 60 * 24)
      ),
    }
  }, [periodDate, cycleLength])

  const calendarDays = useMemo(() => {
    const year = viewMonth.getFullYear()
    const month = viewMonth.getMonth()
    const firstDay = new Date(year, month, 1)
    const lastDay = new Date(year, month + 1, 0)
    const startPadding = firstDay.getDay()
    const days: { date: Date; phase: string | null; isCurrentMonth: boolean }[] = []

    // Add padding days from previous month
    for (let i = startPadding - 1; i >= 0; i--) {
      const date = new Date(year, month, -i)
      days.push({ date, phase: null, isCurrentMonth: false })
    }

    // Add days of current month
    const lastPeriod = new Date(periodDate)
    for (let day = 1; day <= lastDay.getDate(); day++) {
      const date = new Date(year, month, day)
      const daysSince = Math.floor(
        (date.getTime() - lastPeriod.getTime()) / (1000 * 60 * 60 * 24)
      )
      
      let phase: string | null = null
      if (daysSince >= 0) {
        const cycleDay = (daysSince % cycleLength) + 1
        if (cycleDay <= 5) phase = 'menstrual'
        else if (cycleDay <= 13) phase = 'follicular'
        else if (cycleDay <= 16) phase = 'ovulation'
        else phase = 'luteal'
      }
      
      days.push({ date, phase, isCurrentMonth: true })
    }

    // Add padding days from next month
    const endPadding = 42 - days.length
    for (let i = 1; i <= endPadding; i++) {
      const date = new Date(year, month + 1, i)
      days.push({ date, phase: null, isCurrentMonth: false })
    }

    return days
  }, [viewMonth, periodDate, cycleLength])

  const currentPhase = cyclePhases[cycleInfo.phase]
  const today = new Date()

  const getPhaseColor = (phase: string | null) => {
    if (!phase) return ''
    switch (phase) {
      case 'menstrual':
        return 'bg-rose-200'
      case 'follicular':
        return 'bg-amber-200'
      case 'ovulation':
        return 'bg-emerald-200'
      case 'luteal':
        return 'bg-blue-200'
      default:
        return ''
    }
  }

  return (
    <div className="space-y-6">
      <Card className="border-rose-100 bg-gradient-to-br from-rose-50/50 to-pink-50/30">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-lg">
            <Heart className="h-5 w-5 text-rose-500" />
            Menstrual Cycle Tracker
          </CardTitle>
          <CardDescription>Track and understand your cycle phases</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="lastPeriod">Last Period Date</Label>
              <Input
                id="lastPeriod"
                type="date"
                value={periodDate}
                onChange={(e) => setPeriodDate(e.target.value)}
                className="bg-white"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="cycleLength">Cycle Length (days)</Label>
              <Input
                id="cycleLength"
                type="number"
                min={21}
                max={35}
                value={cycleLength}
                onChange={(e) => setCycleLength(parseInt(e.target.value) || 28)}
                className="bg-white"
              />
            </div>
          </div>

          <div className="grid gap-4 sm:grid-cols-3">
            <div className="rounded-xl border border-rose-200 bg-white p-4 text-center">
              <p className="text-sm text-muted-foreground">Cycle Day</p>
              <p className="text-3xl font-bold text-foreground">{cycleInfo.cycleDay}</p>
              <p className="text-xs text-muted-foreground">of {cycleLength}</p>
            </div>
            <div className="rounded-xl border border-rose-200 bg-white p-4 text-center">
              <p className="text-sm text-muted-foreground">Next Period</p>
              <p className="text-lg font-semibold text-foreground">
                {cycleInfo.nextPeriod.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
              </p>
              <p className="text-xs text-muted-foreground">
                in {cycleInfo.daysUntilNextPeriod} days
              </p>
            </div>
            <div className="rounded-xl border border-rose-200 bg-white p-4 text-center">
              <p className="text-sm text-muted-foreground">Current Phase</p>
              <Badge className={`${currentPhase.bgColor} ${currentPhase.color} mt-1`}>
                {currentPhase.name.split(' ')[0]}
              </Badge>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-lg">
            <Calendar className="h-5 w-5 text-primary" />
            Cycle Calendar
          </CardTitle>
          <div className="flex items-center justify-between">
            <CardDescription>
              {viewMonth.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}
            </CardDescription>
            <div className="flex gap-1">
              <Button
                variant="outline"
                size="icon"
                onClick={() => setViewMonth(new Date(viewMonth.getFullYear(), viewMonth.getMonth() - 1))}
              >
                <ChevronLeft className="h-4 w-4" />
              </Button>
              <Button
                variant="outline"
                size="icon"
                onClick={() => setViewMonth(new Date(viewMonth.getFullYear(), viewMonth.getMonth() + 1))}
              >
                <ChevronRight className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-7 gap-1 text-center">
            {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => (
              <div key={day} className="py-2 text-xs font-medium text-muted-foreground">
                {day}
              </div>
            ))}
            {calendarDays.map((day, i) => {
              const isToday = day.date.toDateString() === today.toDateString()
              return (
                <div
                  key={i}
                  className={`relative rounded-lg p-2 text-sm ${
                    !day.isCurrentMonth
                      ? 'text-muted-foreground/30'
                      : isToday
                      ? 'font-bold ring-2 ring-primary'
                      : ''
                  } ${day.isCurrentMonth && day.phase ? getPhaseColor(day.phase) : ''}`}
                >
                  {day.date.getDate()}
                </div>
              )
            })}
          </div>

          <div className="mt-4 flex flex-wrap justify-center gap-4 text-xs">
            <div className="flex items-center gap-1.5">
              <div className="h-3 w-3 rounded-full bg-rose-200" />
              <span>Menstrual</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="h-3 w-3 rounded-full bg-amber-200" />
              <span>Follicular</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="h-3 w-3 rounded-full bg-emerald-200" />
              <span>Ovulation</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="h-3 w-3 rounded-full bg-blue-200" />
              <span>Luteal</span>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card className={currentPhase.bgColor}>
        <CardHeader>
          <CardTitle className={`flex items-center gap-2 text-lg ${currentPhase.color}`}>
            <Info className="h-5 w-5" />
            {currentPhase.name}
          </CardTitle>
          <CardDescription className={currentPhase.color}>{currentPhase.description}</CardDescription>
        </CardHeader>
        <CardContent>
          <p className={`mb-3 font-medium ${currentPhase.color}`}>Health Tips:</p>
          <ul className="space-y-2">
            {currentPhase.tips.map((tip, i) => (
              <li key={i} className="flex items-start gap-2 text-sm text-foreground">
                <span className={`mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full ${currentPhase.color.replace('text-', 'bg-')}`} />
                {tip}
              </li>
            ))}
          </ul>
        </CardContent>
      </Card>
    </div>
  )
}
