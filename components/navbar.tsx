'use client'

import { Activity, User, Stethoscope } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { useApp } from '@/lib/app-context'
import type { Role } from '@/lib/types'

export function Navbar() {
  const { role, setRole, patients, selectedPatientId, setSelectedPatientId } = useApp()

  return (
    <header className="sticky top-0 z-50 border-b border-border bg-card/95 backdrop-blur supports-[backdrop-filter]:bg-card/80">
      <div className="container mx-auto flex h-16 items-center justify-between gap-4 px-4">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary">
            <Activity className="h-5 w-5 text-primary-foreground" />
          </div>
          <div>
            <h1 className="text-lg font-semibold text-foreground">Medbridge</h1>
            <p className="text-xs text-muted-foreground">AI Healthcare Assistant</p>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <Select value={selectedPatientId} onValueChange={setSelectedPatientId}>
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder="Select patient" />
            </SelectTrigger>
            <SelectContent>
              {patients.map((patient) => (
                <SelectItem key={patient.id} value={patient.id}>
                  {patient.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          <div className="flex items-center gap-2 rounded-lg border border-border bg-muted/50 p-1">
            <Button
              variant={role === 'patient' ? 'default' : 'ghost'}
              size="sm"
              onClick={() => setRole('patient')}
              className="gap-2"
            >
              <User className="h-4 w-4" />
              Patient
            </Button>
            <Button
              variant={role === 'doctor' ? 'default' : 'ghost'}
              size="sm"
              onClick={() => setRole('doctor')}
              className="gap-2"
            >
              <Stethoscope className="h-4 w-4" />
              Doctor
            </Button>
          </div>

          <RoleBadge role={role} />
        </div>
      </div>
    </header>
  )
}

function RoleBadge({ role }: { role: Role }) {
  if (role === 'patient') {
    return (
      <Badge variant="secondary" className="gap-1.5 bg-secondary text-secondary-foreground">
        <span className="h-2 w-2 rounded-full bg-emerald-500" />
        Patient Mode
      </Badge>
    )
  }

  return (
    <Badge variant="secondary" className="gap-1.5 bg-primary/10 text-primary">
      <span className="h-2 w-2 rounded-full bg-primary" />
      Doctor Mode
    </Badge>
  )
}
