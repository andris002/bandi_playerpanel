const app = Vue.createApp({
    data() {
        return {
            opened: false,
            onlyonline: false,
            secondshowed: false,
            secondcon: '',
            search: '',
            selectedmem: {},
            members: [],
            copied: {}
        }
    },
    computed: {
        Search(){

            if(this.onlyonline){
                return this.members.filter(mem => {
                    return mem.online === true
                });
            }

            if(this.search === ''){return this.members}

            

            const lower = this.search.toLowerCase()

            return this.members.filter(mem => {
                return mem.firstname.toLowerCase().includes(lower) || 
                        mem.lastname.toLowerCase().includes(lower)
            });

        }
    },
    methods: {
        key(e){if(e.key === 'Escape'){this.OpenPanel(false)}},
        OpenPanel(s){
            const panel = document.querySelector('.panel')
            if(s){
                this.opened = true
                panel.style = 'animation: megnyit 0.3s ease-in;'
                setTimeout(()=>{
                    panel.style = 'opacity: 1'

                }, 290)
            } else {
                fetch(`https://${GetParentResourceName()}/close`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({})
                })
                .then(r => {
                    if (r.ok){
                        if(this.secondshowed){this.OpenSecond(false)}
                        setTimeout(() => {
                            panel.style = 'animation: bezar 0.3s ease-in;'
                            setTimeout(()=>{
                                panel.style = 'opacity: 0'
                                this.opened = false
                            }, 290)
                        }, 300);
                    }
                })
            }
        },
        OpenSecond(s){
            const second = document.querySelector('.secondpanel')
            if(s){
                this.secondshowed = true
                second.style = 'animation: secondmegnyit 0.3s ease-in;'
                setTimeout(()=>{
                    second.style = 'left: 62%;'
                }, 290)
            } else {
                second.style = 'animation: secondbezar 0.3s ease-in;'
                setTimeout(()=>{
                    second.style = 'left: 100%;'
                    this.secondshowed = false
                }, 290)
            }
        },
        SetSecondCon(name){
            if(!this.secondshowed){this.OpenSecond(true)}
            this.secondcon = name
        },
        Cut(word) {
            if (!word) return ""; 
            if (word.length > 10) {
                return word.substring(0, 10)+'...'; 
            }
            return word;
        },
        ClipBoard(n){
            this.copied[n] = true
            const textToCopy = this.selectedmem[n];

            const temp = document.createElement("input");
            temp.value = textToCopy;
            document.body.appendChild(temp);

            temp.select();
            document.execCommand("copy");

            document.body.removeChild(temp);
            setTimeout(()=>{this.copied[n] = false}, 1000)
        },
        Heal(id){
            fetch(`https://${GetParentResourceName()}/healp`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(id)
            })
            .then(r => {
                if (r.ok){
                    this.OpenPanel(false)
                }
            })
        },
        Kill(id){
            fetch(`https://${GetParentResourceName()}/killp`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(id)
            })
            .then(r => {
                if (r.ok){
                    this.OpenPanel(false)
                }
            })
        },
        Kick(){
            fetch(`https://${GetParentResourceName()}/kick`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    reason: kickR.value,
                    id: this.selectedmem.identifier
                })
            })
            .then(r => {
                if (r.ok){
                    this.OpenPanel(false)
                }
            })
        },
        Ban(){
            fetch(`https://${GetParentResourceName()}/ban`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    reason: banR.value,
                    id: this.selectedmem.identifier
                })
            })
            .then(r => {
                if (r.ok){
                    this.OpenPanel(false)
                }
            })
        },
        UB(id){
            fetch(`https://${GetParentResourceName()}/unban`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(id)
            })
            .then(r => {
                if (r.ok){
                    this.OpenPanel(false)
                }
            })
        }
    },
    mounted() {
        window.addEventListener('keydown', this.key)

        window.addEventListener('message', (e) => {
            const data = e.data
            switch(data.type){
                case 'open':
                    this.OpenPanel(true)
                    this.members = data.pl 
                    break
                default:
                    break
            }
        })
    },
})
app.mount('#app');