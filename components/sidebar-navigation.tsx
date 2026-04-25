'use client'

import {
  LayoutDashboard,
  CreditCard,
  Pill,
  AlertTriangle,
  MessageCircle,
  LogOut,
  Activity,
  User,
  Stethoscope,
} from 'lucide-react'
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

export type Page = 'dashboard' | 'health-card' | 'prescriptions' | 'emergency' | 'chat'

const navItems: { id: Page; label: string; icon: typeof LayoutDashboard }[] = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'health-card', label: 'Health Card', icon: CreditCard },
  { id: 'prescriptions', label: 'Prescriptions', icon: Pill },
  { id: 'emergency', label: 'Emergency', icon: AlertTriangle },
  { id: 'chat', label: 'Chat', icon: MessageCircle },
]

interface SidebarNavigationProps {
  currentPage: Page
  onPageChange: (page: Page) => void
  onLogout: () => void
}

export function SidebarNavigation({ currentPage, onPageChange, onLogout }: SidebarNavigationProps) {
  const { role, patients, selectedPatientId, setSelectedPatientId } = useApp()

  return (
    <aside className="flex h-screen w-64 shrink-0 flex-col border-r border-border bg-card">
      <div className="flex items-center gap-3 border-b border-border p-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary">
          <Activity className="h-5 w-5 text-primary-foreground" />
        </div>
        <div>
          <h1 className="font-semibold text-foreground">Medbridge</h1>
          <p className="text-xs text-muted-foreground">Healthcare Assistant</p>
        </div>
      </div>

      <div className="border-b border-border p-4">
        <RoleBadge role={role} />
      </div>

      {role === 'doctor' && (
        <div className="border-b border-border p-4">
          <label className="mb-2 block text-xs font-medium text-muted-foreground">
            Select Patient
          </label>
          <Select value={selectedPatientId} onValueChange={setSelectedPatientId}>
            <SelectTrigger className="w-full">
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
        </div>
      )}

      <nav className="flex-1 space-y-1 p-3">
        {navItems.map((item) => {
          const isActive = currentPage === item.id
          const isEmergency = item.id === 'emergency'

          return (
            <button
              key={item.id}
              onClick={() => onPageChange(item.id)}
              className={`flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
                isActive
                  ? isEmergency
                    ? 'bg-destructive/10 text-destructive'
                    : 'bg-primary/10 text-primary'
                  : isEmergency
                    ? 'text-muted-foreground hover:bg-destructive/5 hover:text-destructive'
                    : 'text-muted-foreground hover:bg-muted hover:text-foreground'
              }`}
            >
              <item.icon className="h-5 w-5" />
              {item.label}
            </button>
          )
        })}
      </nav>

      <div className="border-t border-border p-3">
        <Button
          variant="ghost"
          className="w-full justify-start gap-3 text-muted-foreground hover:text-foreground"
          onClick={onLogout}
        >
          <LogOut className="h-5 w-5" />
          Log Out
        </Button>
      </div>
    </aside>
  )
}

function RoleBadge({ role }: { role: Role }) {
  if (role === 'patient') {
    return (
      <Badge
        variant="secondary"
        className="w-full justify-center gap-2 bg-emerald-500/10 py-2 text-emerald-600"
      >
        <User className="h-4 w-4" />
        Patient Account
      </Badge>
    )
  }

  return (
    <Badge
      variant="secondary"
      className="w-full justify-center gap-2 bg-primary/10 py-2 text-primary"
    >
      <Stethoscope className="h-4 w-4" />
      Doctor Account
    </Badge>
  )
}
