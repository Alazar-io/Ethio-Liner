import type { EmergencyCondition } from './types'

export const emergencyConditions: EmergencyCondition[] = [
  {
    id: 'chest-pain',
    name: 'Chest Pain',
    icon: 'Heart',
    urgencyLevel: 'critical',
    steps: [
      'Call emergency services (911) immediately',
      'Have the person sit or lie down in a comfortable position',
      'Loosen any tight clothing around chest and neck',
      'If prescribed, help them take nitroglycerin',
      'If available and not allergic, give aspirin (325mg) to chew',
      'If the person becomes unresponsive, begin CPR',
      'Use an AED if available and follow its instructions',
      'Stay with the person until help arrives',
    ],
  },
  {
    id: 'bleeding',
    name: 'Bleeding',
    icon: 'Droplets',
    urgencyLevel: 'critical',
    steps: [
      'Call emergency services (911) for severe bleeding',
      'Put on gloves if available to protect yourself',
      'Apply firm, direct pressure to the wound with a clean cloth',
      'Keep applying pressure - do not remove the cloth',
      'If blood soaks through, add more cloth on top',
      'Elevate the injured area above the heart if possible',
      'For limb injuries, apply a tourniquet if bleeding is life-threatening',
      'Keep the person warm and calm until help arrives',
    ],
  },
  {
    id: 'fainting',
    name: 'Fainting',
    icon: 'User',
    urgencyLevel: 'high',
    steps: [
      'Help the person lie down flat on their back',
      'Elevate their legs about 12 inches if no injury is suspected',
      'Loosen any tight clothing, belts, or collars',
      'Check for breathing and pulse',
      'Turn them on their side if they vomit',
      'Do not give them anything to eat or drink',
      'Keep them lying down for at least 10-15 minutes',
      'Call 911 if they do not regain consciousness within 1 minute',
    ],
  },
]
