'use client'

import {
  Pill,
  AlertTriangle,
  Bot,
  FileHeart,
  Calendar,
  Activity,
  Heart,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { useApp } from '@/lib/app-context'
import type { Page } from '@/components/sidebar-navigation'

interface QuickActionProps {
  icon: React.ReactNode
  title: string
  description: string
  onClick: () => void
  variant?: 'default' | 'emergency' | 'agent'
}

function QuickAction({ icon, title, description, onClick, variant = 'default' }: QuickActionProps) {
  const baseStyles =
    'group cursor-pointer transition-all hover:shadow-md hover:-translate-y-0.5'
  const variantStyles =
    variant === 'emergency'
      ? 'border-destructive/30 bg-destructive/5 hover:border-destructive/50'
      : variant === 'agent'
        ? 'border-emerald-500/30 bg-emerald-500/5 hover:border-emerald-500/50'
        : 'hover:border-primary/30'

  return (
    <Card className={`${baseStyles} ${variantStyles}`} onClick={onClick}>
      <CardContent className="flex items-center gap-4 p-4">
        <div
          className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-xl transition-colors ${
            variant === 'emergency'
              ? 'bg-destructive/10 text-destructive group-hover:bg-destructive/20'
              : variant === 'agent'
                ? 'bg-emerald-500/10 text-emerald-600 group-hover:bg-emerald-500/20'
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
  onNavigate: (page: Page) => void
}

export function Dashboard({ onNavigate }: DashboardProps) {
  const { user } = useApp()

  if (!user) {
    return (
      <div className="flex h-64 items-center justify-center">
        <p className="text-muted-foreground">Please log in to view dashboard</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Welcome Card */}
      <Card className="border-0 bg-gradient-to-r from-primary/10 via-primary/5 to-transparent">
        <CardContent className="flex items-center gap-4 p-6">
          <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/10">
            <Activity className="h-7 w-7 text-primary" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-foreground">Welcome, {user.name}</h1>
            <p className="text-muted-foreground">
              {user.condition ? `Managing: ${user.condition}` : 'Your health dashboard is ready'}
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Health Summary Cards */}
      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardContent className="flex items-center gap-4 p-4">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-emerald-500/10">
              <Heart className="h-5 w-5 text-emerald-600" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Health Status</p>
              <p className="font-semibold text-foreground">Good</p>
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
              <p className="text-sm text-muted-foreground">Last Activity</p>
              <p className="font-semibold text-foreground">Today</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions */}
      <div>
        <h2 className="mb-4 text-lg font-semibold text-foreground">Quick Actions</h2>
        <div className="grid gap-4 sm:grid-cols-2">
          <QuickAction
            icon={<FileHeart className="h-6 w-6" />}
            title="Health Record"
            description="View your complete health profile"
            onClick={() => onNavigate('health-record')}
          />
          <QuickAction
            icon={<Pill className="h-6 w-6" />}
            title="Prescriptions"
            description="Upload and manage prescriptions"
            onClick={() => onNavigate('prescriptions')}
          />
          <QuickAction
            icon={<AlertTriangle className="h-6 w-6" />}
            title="Emergency Help"
            description="Get urgent first aid guidance"
            onClick={() => onNavigate('emergency')}
            variant="emergency"
          />
          <QuickAction
            icon={<Bot className="h-6 w-6" />}
            title="AI Health Agent"
            description="Get intelligent health analysis"
            onClick={() => onNavigate('agent')}
            variant="agent"
          />
        </div>
      </div>

      {/* Recent Prescriptions */}
      {user.prescriptions.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-lg">
              <Pill className="h-5 w-5 text-primary" />
              Recent Prescriptions
            </CardTitle>
            <CardDescription>Your latest prescribed medications</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {user.prescriptions.slice(-3).map((rx) => (
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
                  <Badge variant="outline">{rx.prescribedDate}</Badge>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
