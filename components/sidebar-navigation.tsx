'use client'

import {
  LayoutDashboard,
  FileHeart,
  Pill,
  AlertTriangle,
  Bot,
  LogOut,
  Activity,
  User,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { useApp } from '@/lib/app-context'

export type Page = 'dashboard' | 'health-record' | 'prescriptions' | 'emergency' | 'agent'

const navItems: { id: Page; label: string; icon: typeof LayoutDashboard }[] = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'health-record', label: 'Health Record', icon: FileHeart },
  { id: 'prescriptions', label: 'Prescriptions', icon: Pill },
  { id: 'emergency', label: 'Emergency Help', icon: AlertTriangle },
  { id: 'agent', label: 'AI Health Agent', icon: Bot },
]

interface SidebarNavigationProps {
  currentPage: Page
  onPageChange: (page: Page) => void
  onLogout: () => void
}

export function SidebarNavigation({ currentPage, onPageChange, onLogout }: SidebarNavigationProps) {
  const { user } = useApp()

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

      {user && (
        <div className="border-b border-border p-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10">
              <User className="h-5 w-5 text-primary" />
            </div>
            <div className="min-w-0 flex-1">
              <p className="truncate font-medium text-foreground">{user.name}</p>
              <p className="text-xs text-muted-foreground">
                {user.age} years old
              </p>
            </div>
          </div>
        </div>
      )}

      <nav className="flex-1 space-y-1 p-3">
        {navItems.map((item) => {
          const isActive = currentPage === item.id
          const isEmergency = item.id === 'emergency'
          const isAgent = item.id === 'agent'

          return (
            <button
              key={item.id}
              onClick={() => onPageChange(item.id)}
              className={`flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
                isActive
                  ? isEmergency
                    ? 'bg-destructive/10 text-destructive'
                    : isAgent
                      ? 'bg-emerald-500/10 text-emerald-600'
                      : 'bg-primary/10 text-primary'
                  : isEmergency
                    ? 'text-muted-foreground hover:bg-destructive/5 hover:text-destructive'
                    : isAgent
                      ? 'text-muted-foreground hover:bg-emerald-500/5 hover:text-emerald-600'
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
