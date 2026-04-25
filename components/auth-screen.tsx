'use client'

import { useState } from 'react'
import { Activity, Shield, Lock, ChevronRight, User, Calendar, Heart, Sparkles } from 'lucide-react'
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
import { cn } from '@/lib/utils'
import type { User as UserType } from '@/lib/types'

interface AuthScreenProps {
  onLogin: (user: UserType) => void
}

type AuthTab = 'signup' | 'login'

export function AuthScreen({ onLogin }: AuthScreenProps) {
  const [activeTab, setActiveTab] = useState<AuthTab>('signup')
  const [formData, setFormData] = useState({
    name: '',
    age: '',
    gender: '' as 'Male' | 'Female' | 'Other' | '',
    condition: '',
  })
  const [error, setError] = useState('')
  const [focusedField, setFocusedField] = useState<string | null>(null)

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

    if (activeTab === 'signup' && !formData.gender) {
      setError('Please select your gender')
      return
    }

    const newUser: UserType = {
      name: formData.name.trim(),
      age: parseInt(formData.age),
      gender: (formData.gender || 'Other') as 'Male' | 'Female' | 'Other',
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

  return (
    <div className="flex min-h-screen">
      {/* Left Side - Branding */}
      <div className="relative hidden w-1/2 flex-col justify-between overflow-hidden bg-gradient-to-br from-primary/5 via-primary/10 to-accent/20 p-12 lg:flex">
        {/* Abstract Healthcare Visuals */}
        <div className="pointer-events-none absolute inset-0 overflow-hidden">
          {/* Soft gradient orbs */}
          <div className="absolute -left-20 -top-20 h-96 w-96 rounded-full bg-primary/10 blur-3xl" />
          <div className="absolute -bottom-32 -right-32 h-[500px] w-[500px] rounded-full bg-accent/20 blur-3xl" />
          <div className="absolute left-1/2 top-1/2 h-72 w-72 -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary/5 blur-2xl" />
          
          {/* Abstract wave lines */}
          <svg className="absolute bottom-0 left-0 h-64 w-full opacity-30" viewBox="0 0 1440 320" preserveAspectRatio="none">
            <path fill="currentColor" className="text-primary/20" d="M0,160L48,176C96,192,192,224,288,213.3C384,203,480,149,576,138.7C672,128,768,160,864,181.3C960,203,1056,213,1152,197.3C1248,181,1344,139,1392,117.3L1440,96L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z" />
          </svg>
          <svg className="absolute bottom-0 left-0 h-48 w-full opacity-20" viewBox="0 0 1440 320" preserveAspectRatio="none">
            <path fill="currentColor" className="text-accent/30" d="M0,224L48,213.3C96,203,192,181,288,181.3C384,181,480,203,576,218.7C672,235,768,245,864,234.7C960,224,1056,192,1152,181.3C1248,171,1344,181,1392,186.7L1440,192L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z" />
          </svg>

          {/* Floating medical icons */}
          <div className="absolute left-[15%] top-[20%] flex h-16 w-16 items-center justify-center rounded-2xl bg-white/60 shadow-lg backdrop-blur-sm">
            <Heart className="h-8 w-8 text-pink-400" />
          </div>
          <div className="absolute right-[20%] top-[35%] flex h-14 w-14 items-center justify-center rounded-xl bg-white/60 shadow-lg backdrop-blur-sm">
            <Activity className="h-7 w-7 text-primary" />
          </div>
          <div className="absolute bottom-[30%] left-[25%] flex h-12 w-12 items-center justify-center rounded-xl bg-white/60 shadow-lg backdrop-blur-sm">
            <Sparkles className="h-6 w-6 text-accent-foreground" />
          </div>
        </div>

        {/* Logo and Branding */}
        <div className="relative z-10">
          <div className="flex items-center gap-3">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary shadow-lg">
              <Activity className="h-6 w-6 text-primary-foreground" />
            </div>
            <span className="text-2xl font-bold text-foreground">Medbridge</span>
          </div>
        </div>

        {/* Tagline */}
        <div className="relative z-10 max-w-md">
          <h1 className="text-4xl font-bold leading-tight tracking-tight text-foreground">
            Your personal health companion,{' '}
            <span className="text-primary">simplified</span> and{' '}
            <span className="text-accent-foreground">secure</span>.
          </h1>
          <p className="mt-6 text-lg leading-relaxed text-muted-foreground">
            Track your health journey with AI-powered insights, manage prescriptions, 
            and get instant guidance when you need it most.
          </p>

          {/* Feature highlights */}
          <div className="mt-10 space-y-4">
            <div className="flex items-center gap-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-white/80 shadow-sm">
                <Shield className="h-5 w-5 text-primary" />
              </div>
              <span className="text-sm font-medium text-foreground">HIPAA-compliant security</span>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-white/80 shadow-sm">
                <Sparkles className="h-5 w-5 text-primary" />
              </div>
              <span className="text-sm font-medium text-foreground">AI-powered health insights</span>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-white/80 shadow-sm">
                <Heart className="h-5 w-5 text-pink-500" />
              </div>
              <span className="text-sm font-medium text-foreground">Personalized care tracking</span>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="relative z-10 text-sm text-muted-foreground">
          Trusted by thousands of patients worldwide
        </div>
      </div>

      {/* Right Side - Auth Card */}
      <div className="flex w-full flex-col items-center justify-center bg-white px-6 py-12 lg:w-1/2 lg:px-16">
        <div className="w-full max-w-md">
          {/* Mobile Logo */}
          <div className="mb-8 flex items-center justify-center gap-3 lg:hidden">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary shadow-lg">
              <Activity className="h-5 w-5 text-primary-foreground" />
            </div>
            <span className="text-xl font-bold text-foreground">Medbridge</span>
          </div>

          {/* Auth Card */}
          <div className="rounded-3xl border border-border/50 bg-white p-8 shadow-xl shadow-primary/5">
            {/* Tab Switcher */}
            <div className="mb-8 flex rounded-xl bg-muted/50 p-1">
              <button
                type="button"
                onClick={() => setActiveTab('signup')}
                className={cn(
                  'flex-1 rounded-lg py-3 text-sm font-semibold transition-all duration-200',
                  activeTab === 'signup'
                    ? 'bg-white text-foreground shadow-sm'
                    : 'text-muted-foreground hover:text-foreground'
                )}
              >
                Sign Up
              </button>
              <button
                type="button"
                onClick={() => setActiveTab('login')}
                className={cn(
                  'flex-1 rounded-lg py-3 text-sm font-semibold transition-all duration-200',
                  activeTab === 'login'
                    ? 'bg-white text-foreground shadow-sm'
                    : 'text-muted-foreground hover:text-foreground'
                )}
              >
                Login
              </button>
            </div>

            {/* Header */}
            <div className="mb-6 text-center">
              <h2 className="text-2xl font-bold text-foreground">
                {activeTab === 'signup' ? 'Create your health profile' : 'Welcome back'}
              </h2>
              <p className="mt-2 text-sm text-muted-foreground">
                {activeTab === 'signup'
                  ? 'Start your personalized health journey today'
                  : 'Use your signup details to continue'}
              </p>
            </div>

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-5">
              {/* Name Field */}
              <div className="space-y-2">
                <Label htmlFor="name" className="text-sm font-medium text-foreground">
                  Full Name
                </Label>
                <div className="relative">
                  <User className={cn(
                    'absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 transition-colors',
                    focusedField === 'name' ? 'text-primary' : 'text-muted-foreground'
                  )} />
                  <Input
                    id="name"
                    placeholder="Enter your full name"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    onFocus={() => setFocusedField('name')}
                    onBlur={() => setFocusedField(null)}
                    className="h-12 rounded-xl border-border/60 bg-muted/30 pl-11 text-base transition-all duration-200 placeholder:text-muted-foreground/60 focus:border-primary focus:bg-white focus:ring-2 focus:ring-primary/20"
                  />
                </div>
              </div>

              {/* Age Field */}
              <div className="space-y-2">
                <Label htmlFor="age" className="text-sm font-medium text-foreground">
                  Age
                </Label>
                <div className="relative">
                  <Calendar className={cn(
                    'absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 transition-colors',
                    focusedField === 'age' ? 'text-primary' : 'text-muted-foreground'
                  )} />
                  <Input
                    id="age"
                    type="number"
                    placeholder="Enter your age"
                    value={formData.age}
                    onChange={(e) => setFormData({ ...formData, age: e.target.value })}
                    onFocus={() => setFocusedField('age')}
                    onBlur={() => setFocusedField(null)}
                    className="h-12 rounded-xl border-border/60 bg-muted/30 pl-11 text-base transition-all duration-200 placeholder:text-muted-foreground/60 focus:border-primary focus:bg-white focus:ring-2 focus:ring-primary/20"
                    min="1"
                    max="120"
                  />
                </div>
                <p className="text-xs text-muted-foreground">
                  {activeTab === 'login' && 'Enter the age you used during signup'}
                </p>
              </div>

              {/* Signup-only fields */}
              {activeTab === 'signup' && (
                <>
                  {/* Gender Field */}
                  <div className="space-y-2">
                    <Label htmlFor="gender" className="text-sm font-medium text-foreground">
                      Gender
                    </Label>
                    <Select
                      value={formData.gender}
                      onValueChange={(value) =>
                        setFormData({ ...formData, gender: value as 'Male' | 'Female' | 'Other' })
                      }
                    >
                      <SelectTrigger 
                        id="gender" 
                        className="h-12 rounded-xl border-border/60 bg-muted/30 text-base transition-all duration-200 focus:border-primary focus:bg-white focus:ring-2 focus:ring-primary/20"
                      >
                        <SelectValue placeholder="Select your gender" />
                      </SelectTrigger>
                      <SelectContent className="rounded-xl">
                        <SelectItem value="Male" className="rounded-lg">Male</SelectItem>
                        <SelectItem value="Female" className="rounded-lg">Female</SelectItem>
                        <SelectItem value="Other" className="rounded-lg">Other</SelectItem>
                      </SelectContent>
                    </Select>
                    <p className="text-xs text-muted-foreground">
                      Used for personalized health recommendations
                    </p>
                  </div>

                  {/* Condition Field */}
                  <div className="space-y-2">
                    <Label htmlFor="condition" className="text-sm font-medium text-foreground">
                      Medical Condition{' '}
                      <span className="font-normal text-muted-foreground">(optional)</span>
                    </Label>
                    <Input
                      id="condition"
                      placeholder="e.g., Diabetes, Hypertension"
                      value={formData.condition}
                      onChange={(e) => setFormData({ ...formData, condition: e.target.value })}
                      onFocus={() => setFocusedField('condition')}
                      onBlur={() => setFocusedField(null)}
                      className="h-12 rounded-xl border-border/60 bg-muted/30 text-base transition-all duration-200 placeholder:text-muted-foreground/60 focus:border-primary focus:bg-white focus:ring-2 focus:ring-primary/20"
                    />
                    <p className="text-xs text-muted-foreground">
                      Helps us provide relevant health insights
                    </p>
                  </div>
                </>
              )}

              {/* Error Message */}
              {error && (
                <div className="rounded-lg bg-destructive/10 px-4 py-3 text-sm text-destructive">
                  {error}
                </div>
              )}

              {/* Submit Button */}
              <Button 
                type="submit" 
                className="group h-12 w-full rounded-xl text-base font-semibold shadow-lg shadow-primary/20 transition-all duration-200 hover:shadow-xl hover:shadow-primary/30"
              >
                {activeTab === 'signup' ? 'Create Health Profile' : 'Continue to Medbridge'}
                <ChevronRight className="ml-2 h-4 w-4 transition-transform group-hover:translate-x-1" />
              </Button>
            </form>

            {/* Trust Indicators */}
            <div className="mt-8 space-y-3 border-t border-border/50 pt-6">
              <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground">
                <Lock className="h-3.5 w-3.5" />
                <span>Your data is private and secure</span>
              </div>
              <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground">
                <Shield className="h-3.5 w-3.5" />
                <span>Designed for patient safety and clarity</span>
              </div>
            </div>
          </div>

          {/* Footer */}
          <p className="mt-8 text-center text-xs text-muted-foreground">
            By continuing, you agree to our{' '}
            <button type="button" className="text-primary hover:underline">Terms of Service</button>
            {' '}and{' '}
            <button type="button" className="text-primary hover:underline">Privacy Policy</button>
          </p>
        </div>
      </div>
    </div>
  )
}
