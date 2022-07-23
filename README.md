# 3DCharacterJuly22
 
## Hello!
This is my template character controller that I have been working on for a while. It is certainly not done, and has a long way to go to be fully functional but it has the framework to run multiple character controllers in different conditions and animate them for use on humanoid characters.

## Pictures
![alt text](https://github.com/SentientDragon5/3DCharacterJuly22/blob/main/Images/CharacterJuly22.png?raw=true)
![alt text](https://github.com/SentientDragon5/3DCharacterJuly22/blob/main/Images/Skekejuly22.png?raw=true)
These are the demo characters I am using. One of them is VRoid (go to https://vroid.com/en/studio)
VRoid characters can be exported to .vrm files, which are in the same format as .glb so you can just rename the file to the .glb
The .glb file can be imported to Blender and cleaned up and exported to .fbx
![alt text](https://github.com/SentientDragon5/3DCharacterJuly22/blob/main/Images/ChaseJuly22.png?raw=true)
I made an AI with 3 states: Patrol, Chase, Attack
Patrol: currently just stands still, but I have started work on a PatrolPath system that would have the character walk between a list of points
Chase: Run after the player once the AI has sensed the player's existance (OverlapSphere)
Attack: when in range do an attack
![alt text](https://github.com/SentientDragon5/3DCharacterJuly22/blob/main/Images/DemoScenejuly22.png?raw=true)
This is an overview of the demo scene I was using
![alt text](https://github.com/SentientDragon5/3DCharacterJuly22/blob/main/Images/SwordTrailJuly22.png?raw=true)
I am working on sword trails. Unity's built in TrailRenderer really sucks and I dont know what I am going to do about it. There are many semi cheap solutions on the Asset Store

## Concept
The character Controller works in the following way:
Both UserCharacter and AICharacter derive from a Controller class that holds a list of Moveables
The Moveable class is the base class that any ways to move the character are held.
Then I have HumanoidBaseMovement (derived from Moveable) that is based originally off of Unity Standard Assets 2018's 3rd Person Controller
Other states like Swimming can derive from Moveable, and all Moveables can request control of the character, only one derived Moveable can control movement at once though.
I plan to add overrides to Moveables allowing substates like Carrying something over your head, Attacking, etc.

Currently Attacking is done through the Combatant class which controls the weapon and animation from the weapon over the player.
