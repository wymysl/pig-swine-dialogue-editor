// === NPC, Item, Interactable Data ===
// All entity definitions: positions, dialogue callbacks, onTalk handlers.
import { state } from '../state.js';
import { getNpcLines } from './dialogues.js';

export function createNpcs(callbacks) {
  const { awardBadge, saveGame, flashDialog, startNowakCourtChoice } = callbacks;

  return [
    { id:'pig', name:'Mr. Pig', x:5, y:10, hue:'#c96c78',
      lines: () => getNpcLines('pig'),
      onTalk: () => {
        if (!state.quests.orientation) {
          state.quests.orientation = true;
          state.reputation++;
          awardBadge('orientation');
          saveGame();
        }
      }
    },
    { id:'muras', name:'Muraś', x:4, y:11, hue:'#e0b35b',
      lines: () => getNpcLines('muras'),
      onTalk: () => {
        if (!state.quests.guide) {
          state.quests.guide = true;
          awardBadge('guide');
          saveGame();
        }
      }
    },
    { id:'rak', name:'Rak', x:12, y:14, hue:'#7fb069',
      lines: () => getNpcLines('rak'),
    },
    { id:'wymysl', name:'Wymysl', x:14, y:14, hue:'#d7a84f',
      lines: () => getNpcLines('wymysl'),
    },
    { id:'clerk', name:'Court Clerk', x:14, y:6, hue:'#8bb1e0',
      lines: () => getNpcLines('clerk'),
    },
    { id:'tram', name:'Tram 17 Oracle', x:8, y:15, hue:'#e1d156',
      lines: () => getNpcLines('tram'),
    },
    { id:'archivist', name:'Archivist', x:4, y:4, hue:'#8b5a2b',
      lines: () => getNpcLines('archivist'),
    },
    { id:'judge', name:'Judge', x:19, y:6, hue:'#4a6b8a',
      lines: () => getNpcLines('judge'),
    },
    { id:'barista', name:'Barista', x:19, y:16, hue:'#6b3fa0',
      lines: () => getNpcLines('barista'),
    },
    { id:'nowak', name:'Ms. Nowak', x:10, y:4, hue:'#d46a6b',
      lines: () => getNpcLines('nowak'),
      onTalk: () => {
        if (!state.quests.nowakCase) {
          if (!state.nowakEvidence.notice) {
            state.nowakEvidence.notice = true;
            flashDialog('Landlord Eviction Notice received from Ms. Nowak: "Lease violated due to unauthorized wall decorations (posters)"');
            saveGame();
          }
          startNowakCourtChoice();
        }
      }
    }
  ];
}

export function createItems() {
  return [
    { id:'lawBinder', x:4, y:9, label:'Polish law binder', kind:'binder', taken:false },
    { id:'rightsMemo', x:9, y:7, label:'human rights memo', kind:'usb', taken:false },
    { id:'leaseAgreement', x:11, y:4, label:'Lease Agreement', kind:'document', taken:false, evidenceFor:'nowak' },
    { id:'humanRightsPoster', x:18, y:14, label:'Human Rights Poster', kind:'poster', taken:false, evidenceFor:'nowak' },
    { id:'ancientCaseFiles', x:3, y:3, label:'Ancient Case Files', kind:'files', taken:false, hidden:true },
    { id:'courtStamps', x:20, y:5, label:'Court Stamps', kind:'stamps', taken:false, hidden:true },
    { id:'specialtyCoffee', x:20, y:15, label:'Specialty Coffee Beans', kind:'coffee', taken:false, hidden:true }
  ];
}

export function createInteractables() {
  return [
    { id:'coffeeMachine', name:'Coffee Machine', x:6, y:10, label:'Coffee Machine' }
  ];
}
