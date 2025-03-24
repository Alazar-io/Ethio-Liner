'use client'

import {
  User,
  Calendar,
  Activity,
  AlertCircle,
  Pill,
  Stethoscope,
  FileText,
  Heart,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { useApp } from '@/lib/app-context'
import { CycleTracker } from './cycle-tracker'

export function HealthRecord() {
  const { user } = useApp()

  if (!user) {
    return (
      <div className="flex h-64 items-center justify-center">
        <p className="text-muted-foreground">Please log in to view your health record</p>
      </div>
    )
  }

  const getMedicalHistoryIcon = (type: string) => {
    switch (type) {
      case 'diagnosis':
        return <Activity className="h-4 w-4 text-primary" />
      case 'procedure':
        return <Stethoscope className="h-4 w-4 text-blue-500" />
      case 'vaccination':
        return <Pill className="h-4 w-4 text-emerald-500" />
      case 'allergy':
        return <AlertCircle className="h-4 w-4 text-amber-500" />
      default:
        return <FileText className="h-4 w-4 text-muted-foreground" />
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-foreground">Health Record</h1>
        <p className="text-muted-foreground">Your complete health profile</p>
      </div>

      {/* Patient Profile Card */}
      <Card>
        <CardHeader>
          <div className="flex items-start gap-4">
            <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10">
              <User className="h-8 w-8 text-primary" />
            </div>
            <div className="flex-1">
              <CardTitle className="text-2xl">{user.name}</CardTitle>
              <CardDescription className="mt-1">
                {user.age} years old | {user.gender}
              </CardDescription>
            </div>
            {user.condition && (
              <Badge variant="secondary" className="bg-primary/10 text-primary">
                {user.condition}
              </Badge>
            )}
          </div>
        </CardHeader>
      </Card>

      {/* Health Overview Cards */}
      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardContent className="flex items-center gap-4 p-4">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-emerald-500/10">
              <Heart className="h-5 w-5 text-emerald-600" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Overall Status</p>
              <p className="font-semibold text-foreground">Healthy</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-4 p-4">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
              <Pill className="h-5 w-5 text-primary" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Active Medications</p>
              <p className="font-semibold text-foreground">{user.prescriptions.length}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-4 p-4">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-amber-500/10">
              <Calendar className="h-5 w-5 text-amber-600" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">History Items</p>
              <p className="font-semibold text-foreground">{user.medicalHistory.length}</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Medical History Timeline */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-lg">
            <Calendar className="h-5 w-5 text-primary" />
            Medical History
          </CardTitle>
          <CardDescription>Your health timeline</CardDescription>
        </CardHeader>
        <CardContent>
          {user.medicalHistory.length === 0 ? (
            <p className="text-sm text-muted-foreground">No medical history records</p>
          ) : (
            <div className="space-y-3">
              {user.medicalHistory.map((item) => (
                <div
                  key={item.id}
                  className="flex items-start gap-3 rounded-lg border border-border p-4"
                >
                  <div className="mt-0.5">{getMedicalHistoryIcon(item.type)}</div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between">
                      <p className="font-medium text-foreground">{item.description}</p>
                      <Badge variant="outline" className="text-xs">
                        {item.type}
                      </Badge>
                    </div>
                    <p className="mt-1 text-sm text-muted-foreground">{item.date}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Notes Section */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-lg">
            <FileText className="h-5 w-5 text-primary" />
            Health Notes
          </CardTitle>
          <CardDescription>Additional health information</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="rounded-lg border border-border bg-muted/30 p-4">
            <p className="text-sm text-muted-foreground">
              {user.condition
                ? `Currently managing ${user.condition}. Regular checkups recommended.`
                : 'No specific health notes. Keep up with regular health checkups.'}
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Menstrual Cycle Tracker for Female Users */}
      {user.gender === 'Female' && user.menstrualData && (
        <CycleTracker
          lastPeriodDate={user.menstrualData.lastPeriodDate}
          cycleLength={user.menstrualData.cycleLength}
        />
      )}
    </div>
  )
}
