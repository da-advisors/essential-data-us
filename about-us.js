/**
 * JavaScript for the About Us page
 * Handles the bio toggle functionality and hover effects
 */

document.addEventListener('DOMContentLoaded', function() {
  // Get all bio toggle elements
  const bioToggleElements = document.querySelectorAll('.bio-toggle');
  
  // Add click event listener to each toggle
  bioToggleElements.forEach(toggle => {
    toggle.addEventListener('click', function() {
      const bio = this.nextElementSibling;
      
      if (bio.style.height === 'auto' || bio.style.height === '') {
        // If bio is visible, hide it
        bio.style.height = bio.scrollHeight + 'px';
        setTimeout(() => {
          bio.style.height = '0';
          this.textContent = 'Read Bio';
        }, 0);
      } else {
        // If bio is hidden, show it
        bio.style.height = bio.scrollHeight + 'px';
        this.textContent = 'Close';
        
        setTimeout(() => {
          bio.style.height = 'auto';
        }, 300);
      }
    });
  });
  
  // For touch devices, add a class to show bio on tap
  if ('ontouchstart' in window || navigator.maxTouchPoints > 0) {
    const teamMembers = document.querySelectorAll('.team-member');
    
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
});
