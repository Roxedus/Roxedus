class NorskProgrammeringBadge extends HTMLElement {
    constructor() {
        super();
    }

    async connectedCallback() {
        const shadow = this.attachShadow({
            mode: "open"
        });

        const anchor = document.createElement("a");
        anchor.setAttribute("class", "badge");
        anchor.setAttribute("href", "https://discord.gg/norsk-programmering");
        anchor.setAttribute("target", "_blank");
        anchor.setAttribute("aria-label", "A badge representing the Discord community Norsk Programmering");

        const left = document.createElement("div");
        left.setAttribute("class", "left");
        left.textContent = "< / >";
        anchor.appendChild(left);

        const separator = document.createElement("div");
        separator.setAttribute("class", "separator");
        anchor.appendChild(separator);

        const right = document.createElement("div");
        right.setAttribute("class", "right");
        right.textContent = "NORSK PROGRAMMERING";
        anchor.appendChild(right);

        const style = document.createElement("style");
        style.textContent = `
        .badge {
            display: flex;
            width: 210px;
            height: 30px;
            border: 1px solid black;
            box-sizing: border-box;
            font-size: 0.7rem;
            text-decoration: none;

            &:active {
                color: initial;
            }

            .left, .right {
                display: flex;
                justify-content: center;
                align-items: center;
                margin: 1px;
                height: calc(100% - 2px);
                font-family: 'Silkscreen';
            }
    
            .left {
                flex: 1;
                background-color: #01a8f4;
                padding: 0 1px;
            }

            .separator {
                width: 1px;
                background-color: black;
            }

            .right {
                flex: 5;
                background-color: #2f3138;
                color: #01a8f4;
                text-transform: uppercase;
            }
        }
        `;

        shadow.appendChild(style);
        shadow.appendChild(anchor);
    }
}

customElements.define('norsk-programmering-badge', NorskProgrammeringBadge);