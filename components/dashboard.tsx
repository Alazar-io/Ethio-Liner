'use client'

import {
  Camera,
  AlertTriangle,
  MessageCircle,
  CreditCard,
  Pill,
  Calendar,
  User,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { useApp } from '@/lib/app-context'

interface QuickActionProps {
  icon: React.ReactNode
  title: string
  description: string
  onClick: () => void
  variant?: 'default' | 'emergency'
}

function QuickAction({ icon, title, description, onClick, variant = 'default' }: QuickActionProps) {
  const baseStyles =
    'group cursor-pointer transition-all hover:shadow-md hover:-translate-y-0.5'
  const variantStyles =
    variant === 'emergency'
      ? 'border-destructive/30 bg-destructive/5 hover:border-destructive/50'
      : 'hover:border-primary/30'

  return (
    <Card className={`${baseStyles} ${variantStyles}`} onClick={onClick}>
      <CardContent className="flex items-center gap-4 p-4">
        <div
          className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-xl transition-colors ${
            variant === 'emergency'
              ? 'bg-destructive/10 text-destructive group-hover:bg-destructive/20'
              : 'bg-primary/10 text-primary group-hover:bg-primary/20'
          }`}
        >
          {icon}
        </div>
        <div className="min-w-0">
          <p className="font-medium text-foreground">{title}</p>
          <p className="text-sm text-muted-foreground">{description}</p>
        </div>
      </CardContent>
    </Card>
  )
}

interface DashboardProps {
  onNavigate: (tab: string) => void
}

export function Dashboard({ onNavigate }: DashboardProps) {
  const { selectedPatient, role } = useApp()

  if (!selectedPatient) {
    return (
      <div className="flex h-64 items-center justify-center">
        <p className="text-muted-foreground">No patient selected</p>
      </div>
    )
  }

  const recentPrescriptions = selectedPatient.prescriptions.slice(-3)

  return (
    <div className="space-y-6">
      {role === 'patient' && (
        <div className="rounded-lg border border-border bg-secondary/30 px-4 py-2">
          <p className="text-sm text-muted-foreground">
            <span className="mr-2 inline-block h-2 w-2 rounded-full bg-amber-500" />
            View Only Mode - You can view your health information but cannot make changes
          </p>
        </div>
      )}

      <div className="grid gap-4 md:grid-cols-2">
        <QuickAction
          icon={<Camera className="h-6 w-6" />}
          title="Scan Prescription"
          description="Upload and analyze prescriptions"
          onClick={() => onNavigate('prescription')}
        />
        <QuickAction
          icon={<AlertTriangle className="h-6 w-6" />}
          title="Emergency Help"
          description="Get urgent first aid guidance"
          onClick={() => onNavigate('emergency')}
          variant="emergency"
        />
        <QuickAction
          icon={<MessageCircle className="h-6 w-6" />}
          title="Ask Assistant"
          description="Chat with AI health assistant"
          onClick={() => onNavigate('chat')}
        />
        <QuickAction
          icon={<CreditCard className="h-6 w-6" />}
          title="Health Card"
          description="View your health profile"
          onClick={() => onNavigate('health-card')}
        />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-lg">
              <User className="h-5 w-5 text-primary" />
              Patient Summary
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-2xl font-semibold text-foreground">{selectedPatient.name}</p>
                <p className="text-muted-foreground">
                  {selectedPatient.age} years old, {selectedPatient.gender}
                </p>
              </div>
              <Badge variant="secondary" className="bg-primary/10 text-primary">
                {selectedPatient.condition}
              </Badge>
            </div>
            <div className="grid gap-3 text-sm">
              <div className="flex justify-between border-b border-border pb-2">
                <span className="text-muted-foreground">Primary Doctor</span>
                <span className="font-medium text-foreground">{selectedPatient.doctor}</span>
              </div>
              <div className="flex justify-between border-b border-border pb-2">
                <span className="text-muted-foreground">Hospital</span>
                <span className="font-medium text-foreground">{selectedPatient.hospital}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Active Medications</span>
                <span className="font-medium text-foreground">
                  {selectedPatient.medications.length}
                </span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-lg">
              <Pill className="h-5 w-5 text-primary" />
              Recent Prescriptions
            </CardTitle>
            <CardDescription>Latest prescribed medications</CardDescription>
          </CardHeader>
          <CardContent>
            {recentPrescriptions.length === 0 ? (
              <p className="text-sm text-muted-foreground">No prescriptions found</p>
            ) : (
              <div className="space-y-3">
                {recentPrescriptions.map((rx) => (
                  <div
                    key={rx.id}
                    className="flex items-center justify-between rounded-lg border border-border bg-muted/30 p-3"
                  >
                    <div>
                      <p className="font-medium text-foreground">{rx.drugName}</p>
                      <p className="text-sm text-muted-foreground">
                        {rx.dosage} - {rx.frequency}
                      </p>
                    </div>
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <Calendar className="h-4 w-4" />
                      {rx.prescribedDate}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
