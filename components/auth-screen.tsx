'use client'

import { useState } from 'react'
import { Activity, ArrowRight, User, Calendar, Heart } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import type { User as UserType } from '@/lib/types'

interface AuthScreenProps {
  onLogin: (user: UserType) => void
}

type AuthMode = 'welcome' | 'signup' | 'login'

export function AuthScreen({ onLogin }: AuthScreenProps) {
  const [mode, setMode] = useState<AuthMode>('welcome')
  const [formData, setFormData] = useState({
    name: '',
    age: '',
    gender: '' as 'Male' | 'Female' | 'Other' | '',
    condition: '',
  })
  const [error, setError] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    if (!formData.name.trim()) {
      setError('Please enter your name')
      return
    }

    if (!formData.age || parseInt(formData.age) < 1 || parseInt(formData.age) > 120) {
      setError('Please enter a valid age')
      return
    }

    if (!formData.gender) {
      setError('Please select your gender')
      return
    }

    const newUser: UserType = {
      name: formData.name.trim(),
      age: parseInt(formData.age),
      gender: formData.gender as 'Male' | 'Female' | 'Other',
      condition: formData.condition.trim() || undefined,
      medications: [],
      medicalHistory: [
        {
          id: '1',
          date: '2024-01-15',
          description: 'Annual health checkup - all vitals normal',
          type: 'diagnosis',
        },
      ],
      prescriptions: [],
      menstrualData:
        formData.gender === 'Female'
          ? {
              lastPeriodDate: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
              cycleLength: 28,
            }
          : undefined,
    }

    onLogin(newUser)
  }

  if (mode === 'welcome') {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center bg-background px-4">
        <div className="w-full max-w-md space-y-8">
          <div className="text-center">
            <div className="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-3xl bg-primary shadow-lg">
              <Activity className="h-10 w-10 text-primary-foreground" />
            </div>
            <h1 className="text-4xl font-bold tracking-tight text-foreground">Medbridge</h1>
            <p className="mt-3 text-lg text-muted-foreground">
              Your AI-powered health companion
            </p>
          </div>

          <div className="space-y-4 pt-4">
            <Button
              className="h-14 w-full gap-3 text-lg"
              onClick={() => setMode('signup')}
            >
              <User className="h-5 w-5" />
              Create Account
              <ArrowRight className="ml-auto h-5 w-5" />
            </Button>

            <Button
              variant="outline"
              className="h-14 w-full gap-3 text-lg"
              onClick={() => setMode('login')}
            >
              Sign In
              <ArrowRight className="ml-auto h-5 w-5" />
            </Button>
          </div>

          <div className="flex items-center justify-center gap-8 pt-8 text-sm text-muted-foreground">
            <div className="flex items-center gap-2">
              <Heart className="h-4 w-4 text-pink-500" />
              <span>Health Tracking</span>
            </div>
            <div className="flex items-center gap-2">
              <Activity className="h-4 w-4 text-primary" />
              <span>AI Assistance</span>
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-background px-4">
      <div className="w-full max-w-md">
        <button
          onClick={() => setMode('welcome')}
          className="mb-6 text-sm text-muted-foreground hover:text-foreground"
        >
          &larr; Back
        </button>

        <Card className="border-0 shadow-xl">
          <CardHeader className="text-center">
            <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/10">
              <Activity className="h-7 w-7 text-primary" />
            </div>
            <CardTitle className="text-2xl">
              {mode === 'signup' ? 'Create Your Account' : 'Welcome Back'}
            </CardTitle>
            <CardDescription>
              {mode === 'signup'
                ? 'Tell us about yourself to get started'
                : 'Sign in with your name and age'}
            </CardDescription>
          </CardHeader>

          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="name">Full Name</Label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    id="name"
                    placeholder="Enter your full name"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="pl-10"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="age">Age</Label>
                <div className="relative">
                  <Calendar className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    id="age"
                    type="number"
                    placeholder="Enter your age"
                    value={formData.age}
                    onChange={(e) => setFormData({ ...formData, age: e.target.value })}
                    className="pl-10"
                    min="1"
                    max="120"
                  />
                </div>
              </div>

              {mode === 'signup' && (
                <>
                  <div className="space-y-2">
                    <Label htmlFor="gender">Gender</Label>
                    <Select
                      value={formData.gender}
                      onValueChange={(value) =>
                        setFormData({ ...formData, gender: value as 'Male' | 'Female' | 'Other' })
                      }
                    >
                      <SelectTrigger id="gender">
                        <SelectValue placeholder="Select your gender" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Male">Male</SelectItem>
                        <SelectItem value="Female">Female</SelectItem>
                        <SelectItem value="Other">Other</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="condition">
                      Medical Condition{' '}
                      <span className="text-muted-foreground">(optional)</span>
                    </Label>
                    <Input
                      id="condition"
                      placeholder="e.g., Diabetes, Hypertension"
                      value={formData.condition}
                      onChange={(e) => setFormData({ ...formData, condition: e.target.value })}
                    />
                  </div>
                </>
              )}

              {error && (
                <p className="text-sm text-destructive">{error}</p>
              )}

              <Button type="submit" className="h-12 w-full gap-2 text-base">
                {mode === 'signup' ? 'Create Account' : 'Sign In'}
                <ArrowRight className="h-4 w-4" />
              </Button>
            </form>

            <div className="mt-6 text-center">
              <button
                type="button"
                onClick={() => setMode(mode === 'signup' ? 'login' : 'signup')}
                className="text-sm text-primary hover:underline"
              >
                {mode === 'signup'
                  ? 'Already have an account? Sign in'
                  : "Don't have an account? Sign up"}
              </button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
