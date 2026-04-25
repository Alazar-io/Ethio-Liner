'use client'

import { Activity, User, Stethoscope, Shield, Heart, Clock } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import type { Role } from '@/lib/types'

interface LoginScreenProps {
  onLogin: (role: Role) => void
}

export function LoginScreen({ onLogin }: LoginScreenProps) {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-background px-4">
      <div className="w-full max-w-md space-y-8">
        <div className="text-center">
          <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-primary shadow-lg">
            <Activity className="h-8 w-8 text-primary-foreground" />
          </div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">
            Welcome to Medbridge
          </h1>
          <p className="mt-2 text-muted-foreground">
            AI-powered healthcare assistant for patients and medical professionals
          </p>
        </div>

        <div className="space-y-4">
          <Card
            className="group cursor-pointer border-2 border-transparent transition-all hover:border-emerald-500/50 hover:shadow-lg"
            onClick={() => onLogin('patient')}
          >
            <CardHeader className="pb-2">
              <div className="flex items-center gap-4">
                <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-600 transition-colors group-hover:bg-emerald-500/20">
                  <User className="h-7 w-7" />
                </div>
                <div>
                  <CardTitle className="text-xl">Login as Patient</CardTitle>
                  <CardDescription>Access your health records and chat with AI</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="flex flex-wrap gap-2">
                <span className="inline-flex items-center gap-1 rounded-full bg-muted px-3 py-1 text-xs text-muted-foreground">
                  <Heart className="h-3 w-3" />
                  View Health Card
                </span>
                <span className="inline-flex items-center gap-1 rounded-full bg-muted px-3 py-1 text-xs text-muted-foreground">
                  <Clock className="h-3 w-3" />
                  Track Medications
                </span>
              </div>
            </CardContent>
          </Card>

          <Card
            className="group cursor-pointer border-2 border-transparent transition-all hover:border-primary/50 hover:shadow-lg"
            onClick={() => onLogin('doctor')}
          >
            <CardHeader className="pb-2">
              <div className="flex items-center gap-4">
                <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-primary/10 text-primary transition-colors group-hover:bg-primary/20">
                  <Stethoscope className="h-7 w-7" />
                </div>
                <div>
                  <CardTitle className="text-xl">Login as Doctor</CardTitle>
                  <CardDescription>Manage patients and prescriptions</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="flex flex-wrap gap-2">
                <span className="inline-flex items-center gap-1 rounded-full bg-muted px-3 py-1 text-xs text-muted-foreground">
                  <Shield className="h-3 w-3" />
                  Full Access
                </span>
                <span className="inline-flex items-center gap-1 rounded-full bg-muted px-3 py-1 text-xs text-muted-foreground">
                  <User className="h-3 w-3" />
                  Patient Management
                </span>
              </div>
            </CardContent>
          </Card>
        </div>

        <p className="text-center text-xs text-muted-foreground">
          Secure healthcare platform with role-based access control
        </p>
      </div>
    </div>
  )
}
