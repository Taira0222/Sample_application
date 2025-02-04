//メニュー操作
//トグルリスナーを追加してクリックをリッスンする
document.addEventListener("turbo:load", function() {
    let account = document.querySelector("#account");
    if (account){
        account.addEventListener("click", function(event) {
            event.preventDefault(); // それ自体が持っているリンクの効果をなくす
            let menu = document.querySelector("#dropdown-menu");
            menu.classList.toggle("active");
        });
    }
});

