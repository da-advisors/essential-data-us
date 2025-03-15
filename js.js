//Public Domain

//Job Number Counter
const jobsKilledTotal = 25339-1;
var currentJobNumber = 0;
const countingInterval_MS = 17;
var counterInterval = window.setInterval( function() {
    currentJobNumber = currentJobNumber + (jobsKilledTotal - currentJobNumber)*0.08;
    document.getElementById("jobsKilled").innerHTML = Math.ceil(currentJobNumber).toLocaleString();
    if(jobsKilledTotal == Math.ceil(currentJobNumber)){
        clearInterval(counterInterval);
    }
  }, countingInterval_MS);

function shuffleArray(array) {
    for (var i = array.length - 1; i >= 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
}
  
//Card Animation
var storyCards = [];
const storyCardParent = document.getElementById("storyGallery");

const speed = 1; 
const spread = 0.09;
var accelerator = 1;
var accelerating = false;
const maxSpeed = 20.0;

function createStoryCards(){
    document.querySelectorAll(".story").forEach(element => {
        //init
        element.style.zIndex = 5 +  Math.floor( Math.random() * 100 );
        storyCards.push({
            node: element, 
            parralax: (0.3+Math.random()*0.7), 
            positionX: Math.random() - 0.5, 
            yOffset:  (Math.cos((2*Math.PI)*Math.random())+1.0)/2.0,        
            //deltaTime: 0, 
            //resetTime: 0
        });
    });
    shuffleArray(storyCards);

    for ( let counter = 0; counter < storyCards.length; counter++ ){
        const parentWidth = storyCardParent.offsetWidth;
        //const parentHeight = storyCardParent.offsetHeight;
        const element = storyCards[counter];
        element.positionX = (parentWidth * spread) * counter + element.positionX * parentWidth/7.0;
    }
}

function updateStoryPositions(){

    storyCardParent.style.height = window.innerHeight * 0.55 + "px";

    const parentWidth = storyCardParent.offsetWidth;
    const parentHeight = storyCardParent.offsetHeight;
    if(accelerating){
        accelerator += (maxSpeed - accelerator) * 0.03; 
    }
    else{
        accelerator += (1.0 - accelerator) * 0.07;
    }

    for ( let counter = 0; counter < storyCards.length; counter++ ){
        const element = storyCards[counter];
        if(!(element.node.matches(":hover"))){

            //height bucketing 64px padding
            element.node.style.top = 32 + ((parentHeight - element.node.offsetHeight - 64 ) / 20.0) * Math.trunc(element.yOffset * 20.0  + 0.5) + "px";
            
            element.positionX -= speed *( parentWidth/1000.0)  * element.parralax * accelerator;

            if ( element.positionX < parentWidth + 10){
                element.node.style.display = "block";
                element.node.style.left = element.positionX + "px";
            }
            else{
                element.node.style.display = "none";
            }

            if ( element.node.getBoundingClientRect().right < 0 ){ //respawn
                element.yOffset = Math.random(); // new yOffset
                element.parralax = (0.3+Math.random()*0.7); // new parralax Rate
                element.node.style.zIndex = 5 + Math.floor(Math.random() * 100);
                element.positionX = parentWidth + (element.node.offsetWidth * (storyCards.length * spread) ) * (Math.random()+0.5);
            }
        }
        else{
            if(element.node.getBoundingClientRect().left < 0){
                element.positionX += ( 10 - element.node.getBoundingClientRect().left ) * 0.1;
            }
            if(element.node.getBoundingClientRect().right > parentWidth){
                element.positionX -= ( element.node.getBoundingClientRect().right - parentWidth + 10 ) * 0.1;
            }
            element.node.style.left = element.positionX + "px";
        }  
    }

}

document.getElementById("storyGallery").addEventListener("mousedown", function(){
    accelerating = true;
});
document.getElementById("storyGallery").addEventListener("mouseup", function(){
    accelerating = false;
});
document.getElementById("storyGallery").addEventListener("mouseleave", function(){
    accelerating = false;
});
document.getElementById("storyGallery").addEventListener("touchdown", function(){
    accelerating = true;
});
document.getElementById("storyGallery").addEventListener("mouseup", function(){
    accelerating = false;
});
document.getElementById("storyGallery").addEventListener("mouseleave", function(){
    accelerating = false;
});

createStoryCards();
window.setInterval(updateStoryPositions, countingInterval_MS);

// About Us page functionality
document.addEventListener('DOMContentLoaded', function() {
  // For touch devices, add a class to show bio on tap
  if ('ontouchstart' in window || navigator.maxTouchPoints > 0) {
    const teamMembers = document.querySelectorAll('.team-member');
    
    if (teamMembers.length > 0) {
      teamMembers.forEach(member => {
        member.addEventListener('click', function() {
          // Remove active class from all other members
          teamMembers.forEach(m => {
            if (m !== member) {
              m.classList.remove('touch-active');
            }
          });
          
          // Toggle active class on the clicked member
          this.classList.toggle('touch-active');
        });
      });
      
      // Close bio when clicking outside
      document.addEventListener('click', function(event) {
        if (!event.target.closest('.team-member')) {
          teamMembers.forEach(member => {
            member.classList.remove('touch-active');
          });
        }
      });
    }
  }
});

// Mobile hamburger menu functionality
document.addEventListener('DOMContentLoaded', function() {
  // Simple toggle for hamburger menu on mobile
  const hamburgerIcon = document.querySelector('.hamburger-menu .fas');
  
  if (hamburgerIcon) {
    hamburgerIcon.addEventListener('click', function(event) {
      event.stopPropagation();
      const menu = this.closest('.hamburger-menu');
      menu.classList.toggle('menu-open');
    });
    
    // Close menu when clicking outside
    document.addEventListener('click', function(event) {
      const openMenus = document.querySelectorAll('.hamburger-menu.menu-open');
      if (openMenus.length > 0 && !event.target.closest('.hamburger-menu')) {
        openMenus.forEach(menu => menu.classList.remove('menu-open'));
      }
    });
  }
});
