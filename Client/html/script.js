$(function(){

    window.addEventListener('message', function(event){
        let item = event.data

        if(item.type == "open"){
            $("#container").fadeIn(150)
        }

        if(item.type == "setChars"){
            let length = item.chars.length
            let charCount = item.charCount
            let chars = 0
            let neededchars = 0

            for (const [key, value] of Object.entries(item.chars)) {
                chars++
            }

            for(let i = 0; i < length; i++){
                InsertChar(item.chars[i])
            } 

            neededchars = charCount-chars
            for(let i = 0; i < neededchars; i++){
                InsertDefaultChar()
            }
        }
    })

    $("body").on('click', '#createchar', function(){
        $(".register").fadeIn(350);
        $(".chars").css('opacity', '0.0')
    })

    $("body").on('click', '#createcharacter', function(){
        let firstname = $("#firstname").val();
        let lastname = $("#lastname").val();
        let age = getAge($("#age").val());
        let height = $("#height").val();
        let sex = $("#sex").val();

        $("#firstnamehelp").html("")
        $("#lastnamehelp").html("")
        $("#agehelp").html("")
        $("#agehelp").html("")
        $("#heighthelp").html("")
        $("#heighthelp").html("")
        
        if(firstname.length < 2){
            $("#firstnamehelp").html("Your firstname needs to be over 2 characters")
        } else if(lastname.length < 3){
            $("#lastnamehelp").html("Your lastname needs to be over 3 characters")
        } else if(age < 18){
            $("#agehelp").html("Your age needs to be over 18")
        } else if(age > 99){
            $("#agehelp").html("Your age needs to be under 99")
        } else if(height > 200){
            $("#heighthelp").html("Your height needs to be under 200 cm")
        } else if(height < 120){
            $("#heighthelp").html("Your height needs to be over 120 cm")
        } else if(sex == "Choose Sex"){
            return
            //$("#sexhelp").html("You need to select a sex")
        } else {
            $.post('https://multicharacter/CreateChar', JSON.stringify({
                firstname: firstname,
                name: lastname,
                sex: sex,
                age: age,
                height: height
            }))
    
            $("#container").fadeOut(150)
            setTimeout(() => {
                ResetUI()
                $(".chars").empty();
            }, 250);
        }
    })

    $("body").on('click', '#closecreation', function(){
        ResetUI()
    })

    $("body").on('click', '.select', function(){
        let user_id = $(this).attr('userid');
        $.post('https://multicharacter/SelectChar', JSON.stringify({user_id: user_id}))

        $("#container").fadeOut(150)
        setTimeout(() => {
            ResetUI()
            $(".chars").empty();
        }, 250);
    })


    $('body').on('click', '.delete', function(){
        let id = $(this).attr('userid');

        $(this).closest("div .char").remove();
        InsertDefaultChar()

        $.post('https://multicharacter/DeleteChar', JSON.stringify({user_id: id}))
    })


    function InsertDefaultChar(){
        $(".chars").append(`
        <div class="char">
            <div class="header">
                <h3>Empty slot</h3>
            </div>
    
            <div class="char-info">
                <i class="fa-solid fa-plus"></i>
            </div>
    
            <button id="createchar" class="create">Create Character</button>
        </div>
        `)
    }
    
    function InsertChar(data){
        $(".chars").append(`
        <div class="char">
            <div class="header">
                <h3>${data.firstname} | ${data.user_id}</h3>
            </div>
    
            <div class="char-info">
                <p>Full Name: <span>${data.firstname} ${data.lastname}</span></p>
                <p>Age: <span>${data.age}</span></p>
                <p>Gender: <span>${data.gender}</span></p>
                <p>Height: <span>${data.height} cm</span></p>
                <p>Job: <span>${data.job}</span></p>
                <p>Phone Number: <span>${data.phonenumber}</span></p>
                <p>Bank Account: <span>$${data.bank}</span></p>
                <p>Cash: <span>$${data.cash}</span></p>
            </div>
            <div class="buttons">
                <button class="select" userid="${data.user_id}">Select Character</button>
                <button class="delete" userid="${data.user_id}">Delete Character</button>
            </div>
        </div>
        `)
    }

    function getAge(dateString) {
        var today = new Date();
        var birthDate = new Date(dateString);
        var age = today.getFullYear() - birthDate.getFullYear();
        var m = today.getMonth() - birthDate.getMonth();

        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }

        return age;
    }

    function ResetUI(){
        $(".register").fadeOut(250);
        $(".chars").css('opacity', '1.0')
        $("#firstname").val('');
        $("#lastname").val('');
        $("#age").val('');
        $("#height").val('');
        $("#sex").val('');
    }
});