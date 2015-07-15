namespace :db do
	desc "Fill database with sample data"
	task populate: :environment do

		#make_emotions
		#make_users
		#make_dreams
		#make_real_dreams
		#make_poem_dreams
		

		
		#make_simple_dreams
		#make_jhad_db
		make_jhad_db2
		#make_comments
		#make_relationships
		#make_votes
	end
end


def make_users
	60.times do |n|
		username = Faker::Internet.user_name
		name = Faker::Name.name
		email = "example-#{n+1}@example.com"
		password = "foobaristooshort"
		User.create!(username: username,
								 name: name,
								 email: email,
								 password: password,
								 password_confirmation: password)
	end
end

def make_dreams
	users = User.all
	users.each do |user|

		20.times do |n|
			title = Faker::Lorem.sentence(5)
			body = Faker::Lorem.paragraphs.join(" ")
			random = [1, rand(1000)].max
			dreamed_on = random.day.ago
			random = [1, random - rand(100)].max
			created_at = random.day.ago
			random = rand(10)
			if random == 9
				impression = 3
			elsif random >= 7
				impression = 2
			else
				impression = 1
			end
			random = rand(10)
			if random > 5
				private = true
			else
				private = false
			end
			random = rand(10)
			if random > 5
				body = body + "#" + Faker::Lorem.word
			end
			dream = user.dreams.create!(title: title, body: body, impression: impression, dreamed_on: dreamed_on, created_at: created_at, private: private)
			dream.liked_by user
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 1)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 2)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 3)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 4)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 5)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 6)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 7)
			end																	
		end		

	end

		user = User.first
		50.times do
			title = Faker::Lorem.sentence(5)
			body = Faker::Lorem.paragraphs.join(" ")
			random = [1, rand(1000)].max
			dreamed_on = random.day.ago
			random = [1, random - rand(100)].max
			created_at = random.day.ago
			random = rand(10)
			if random == 9
				impression = 3
			elsif random >= 7
				impression = 2
			else
				impression = 1
			end
			random = rand(10)
			if random > 5
				private = true
			else
				private = false
			end
			random = rand(10)
			if random > 5
				body = body + "#" + Faker::Lorem.word
			end
			dream = user.dreams.create!(title: title, body: body, impression: impression, dreamed_on: dreamed_on, created_at: created_at, private: private)
			dream.liked_by user
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 1)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 2)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 3)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 4)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 5)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 6)
			end
			random = rand(10)
			if random > 7
				dream.dreamemotions.create(emotion_id: 7)
			end																	
		end

end

def make_votes
	users = User.all
	number = Dream.all.length
	users.each do |user|
		40.times do
			random = rand(number) + 1
			if rand(10) < 9
				Dream.find(random).liked_by user
			else
				Dream.find(random).downvote_from user
			end
		end
	end
end

def make_relationships
	users= User.all
	user = users.first
	following = users[2..9]
	followers = users[13..17]
	following.each { |followed| user.follow(followed) }
	followers.each { |follower| follower.follow(user) }
end

def make_comments
	user = User.first
	dreams = Dream.all(limit: 20)
	dreams.each do |dream| 
		body = Faker::Lorem.paragraphs.join(" ")
		user.comments.create!(dream: dream, body: body)
	end
end

def make_emotions
	Emotion.create!(name: 'Angry')
	Emotion.create!(name: 'Afraid')
	Emotion.create!(name: 'Disgusted')
	Emotion.create!(name: 'Happy')
	Emotion.create!(name: 'Sad')
	Emotion.create!(name: 'Desiring')
	Emotion.create!(name: 'Guilty')
end

def make_poem_dreams
#	user = User.create!(username: 'Blake',
#											name: 'William Blake',
#											email: 'blake@blake.com',
#											password: 'foobaristooshort',
#											password_confirmation: 'foobaristooshort')
user = User.find_by(username: "blake")

	user.dreams.create!(title: 'A Poison Tree',
		body: 'I was angry with my friend:
I told my #wrath, my wrath did end.
I was angry with my #foe:
I told it not, my wrath did grow.

And I watered it in fears,
Night and morning with my tears; 
And I sunned it with smiles,
And with soft deceitful wiles.

And it grew both day and night,
Till it bore an #apple bright.
And my foe beheld it shine.
And he knew that it was mine,

And into my #garden stole
When the night had veiled the pole; 
In the morning glad I see
My foe outstretched beneath the tree.
#human @william ',
dreamed_on: Date.new(2013,2,16))

	user.dreams.create!(title: 'Auguries of Innocence',
		body: "To see a World in a Grain of Sand
And a Heaven in a Wild Flower,
Hold Infinity in the palm of your hand
And Eternity in an hour. 

A Robin Red breast in a Cage
Puts all Heaven in a Rage.
A dove house fill'd with doves & Pigeons
Shudders Hell thro' all its regions.
A dog starv'd at his Master's Gate
Predicts the ruin of the State.
A Horse misus'd upon the Road
Calls to #Heaven for Human blood.
Each outcry of the hunted Hare
A fibre from the Brain does tear.
A Skylark wounded in the wing,
A Cherubim does cease to sing.
The Game Cock clipp'd and arm'd for fight
Does the Rising Sun affright.
Every Wolf's & Lion's howl
Raises from Hell a Human Soul.
The wild deer, wand'ring here & there,
Keeps the Human Soul from Care.
The Lamb misus'd breeds public strife
And yet forgives the Butcher's Knife.
The Bat that flits at close of Eve
Has left the Brain that won't believe.
The Owl that calls upon the Night
Speaks the Unbeliever's fright.
He who shall hurt the little Wren
Shall never be belov'd by Men.
He who the Ox to wrath has mov'd
Shall never be by Woman lov'd.
The wanton Boy that kills the Fly
Shall feel the Spider's enmity.
He who torments the Chafer's sprite
Weaves a Bower in endless Night.
The Catterpillar on the Leaf
Repeats to thee thy Mother's grief.
Kill not the Moth nor Butterfly,
For the Last Judgement draweth nigh.
He who shall train the Horse to War
Shall never pass the Polar Bar.
The Beggar's Dog & Widow's Cat,
Feed them & thou wilt grow fat.
The Gnat that sings his Summer's song
Poison gets from Slander's tongue.
The poison of the Snake & Newt
Is the sweat of Envy's Foot.
The poison of the Honey Bee
Is the Artist's Jealousy.
The Prince's Robes & Beggars' Rags
Are Toadstools on the Miser's Bags.
A truth that's told with bad intent
Beats all the Lies you can invent.
It is right it should be so;
#Man was made for Joy & Woe;
And when this we rightly know
Thro' the World we safely go.
Joy & Woe are woven fine,
A Clothing for the Soul divine;
Under every grief & pine
Runs a joy with silken twine.
The Babe is more than swadling Bands;
Throughout all these Human Lands
Tools were made, & born were hands,
Every Farmer Understands.
Every Tear from Every Eye
Becomes a Babe in Eternity.
This is caught by Females bright
And return'd to its own delight.
The Bleat, the Bark, Bellow & Roar
Are Waves that Beat on Heaven's Shore.
The Babe that weeps the Rod beneath
Writes Revenge in realms of death.
The Beggar's Rags, fluttering in Air,
Does to Rags the Heavens tear.
The Soldier arm'd with Sword & Gun,
Palsied strikes the Summer's Sun.
The poor Man's Farthing is worth more
Than all the Gold on Afric's Shore.
One Mite wrung from the Labrer's hands
Shall buy & sell the Miser's lands:
Or, if protected from on high,
Does that whole Nation sell & buy.
He who mocks the Infant's Faith
Shall be mock'd in Age & Death.
He who shall teach the Child to Doubt
The rotting Grave shall ne'er get out.
He who respects the Infant's faith
Triumph's over Hell & Death.
The Child's Toys & the Old Man's Reasons
Are the Fruits of the Two seasons.
The Questioner, who sits so sly,
Shall never know how to Reply.
He who replies to words of Doubt
Doth put the Light of Knowledge out.
The Strongest Poison ever known
Came from Caesar's Laurel Crown.
Nought can deform the Human Race
Like the Armour's iron brace.
When Gold & Gems adorn the Plow
To peaceful Arts shall Envy Bow.
A Riddle or the Cricket's Cry
Is to Doubt a fit Reply.
The Emmet's Inch & Eagle's Mile
Make Lame Philosophy to smile.
He who Doubts from what he sees
Will ne'er believe, do what you Please.
If the Sun & Moon should doubt
They'd immediately Go out.
To be in a Passion you Good may do,
But no Good if a Passion is in you.
The Whore & Gambler, by the State
Licenc'd, build that Nation's Fate.
The Harlot's cry from Street to Street
Shall weave Old England's winding Sheet.
The Winner's Shout, the Loser's Curse,
Dance before dead England's Hearse.
Every #Night & every Morn
Some to Misery are Born.
Every Morn & every Night
Some are Born to sweet Delight.
Some ar Born to sweet Delight,
Some are born to Endless Night.
We are led to Believe a Lie
When we see not Thro' the #Eye
Which was Born in a Night to Perish in a Night
When the Soul Slept in Beams of Light.
God Appears & God is Light
To those poor Souls who dwell in the Night,
But does a Human Form Display
To those who Dwell in Realms of day. 
#human @william ",
dreamed_on: Date.new(2013,2,16))

	user.dreams.create!(title: 'The Tiger',
		body: 'Tiger! Tiger! burning bright
In the forest of the night
What #immortal hand or #eye
Could frame thy fearful #symmetry? 

In what distant deeps or skies
Burnt the fire of thine eyes? 
On what wings dare he aspire? 
What the hand dare seize the fire? 

And What shoulder, and what art,
Could twist the sinews of thy heart? 
And when thy heart began to beat,
What dread hand? and what dread feet? 

What the hammer? what the chain? 
In what furnace was thy #brain ? 
What the anvil? what dread grasp
Dare its deadly terrors clasp? 

When the stars threw down their spears,
And watered #heaven with their tears,
Did he smile his work to see? 
Did he who made the lamb make thee? 

Tiger! Tiger! burning bright
In the forests of the night,
What immortal hand or eye 
Dare frame thy fearful symmetry? 
#human @william ',
dreamed_on: Date.new(2013,2,16))

		user.dreams.create!(title: "Love's Secret",
		body: "Never seek to tell thy love, 
Love that never told can be;
For the gentle wind does move
Silently, invisibly.

I told my love, I told my love,
I told her all my heart;
Trembling, cold, in ghastly fears,
Ah! she did depart!

Soon as she was gone from me,
A traveler came by,
Silently, invisibly 
He took her with a sigh.
#human @william",
dreamed_on: Date.new(2013,2,16))


		user.dreams.create!(title: "Cradle Song",
		body: "SLEEP, sleep, #beauty bright,
Dreaming in the joys of night;
Sleep, sleep; in thy sleep
Little sorrows sit and weep.
 
Sweet babe, in thy face
Soft desires I can trace,
Secret joys and secret smiles,
Little pretty infant wiles.
 
As thy softest limbs I feel,
Smiles as of the morning steal
O'er thy cheek, and o'er thy breast
Where thy little heart doth rest.
 
O the cunning wiles that creep
In thy little heart asleep!
When thy little heart doth wake,
Then the dreadful night shall break.

#human @william",
dreamed_on: Date.new(2012,2,12))


				user.dreams.create!(title: "The Angel",
		body: "I dreamt a dream! What can it mean?
And that I was a maiden Queen
Guarded by an Angel mild:
Witless woe was ne'er beguiled!

And I wept both night and day,
And he wiped my tears away;
And I wept both day and night,
And hid from him my heart's delight.

So he took his wings, and fled;
Then the morn blushed rosy red.
I dried my tears, and armed my fears
With ten-thousand shields and spears.

Soon my Angel came again;
I was armed, he came in vain;
For the time of youth was fled,
And grey hairs were on my head. 

#human @william",
impression: 2,
dreamed_on: Date.new(2012,2,11))

user.dreams.create!(title: "A Divine Image",
		body: "Cruelty has a human heart,
And Jealousy a human face;
Terror the human form divine,
And Secresy the human dress.

The human dress is forged iron,
The human form a fiery forge,
The human face a furnace sealed,
The human heart its hungry gorge. 

#human @william",
dreamed_on: Date.new(2012,2,11))				



user.dreams.create!(title: "A Cradle Song",
		body: "Sweet dreams form a shade,
O'er my lovely infants head.
Sweet dreams of pleasant streams,
By happy silent moony beams

Sweet sleep with soft down.
Weave thy brows an infant crown.
Sweet sleep Angel mild,
Hover o'er my happy child.

Sweet smiles in the night,
Hover over my delight.
Sweet smiles Mothers smiles,
All the livelong night beguiles.

Sweet moans, dovelike sighs,
Chase not slumber from thy eyes,
Sweet moans, sweeter smiles,
All the dovelike moans beguiles.

Sleep sleep happy child,
All creation slept and smil'd.
Sleep sleep, happy sleep.
While o'er thee thy mother weep

Sweet babe in thy face,
Holy image I can trace.
Sweet babe once like thee.
Thy maker lay and wept for me

Wept for me for thee for all,
When he was an infant small.
Thou his image ever see.
Heavenly face that smiles on thee,

Smiles on thee on me on all,
Who became an infant small,
Infant smiles are His own smiles,
Heaven & earth to peace beguiles. . 

#human @william",
dreamed_on: Date.new(2012,2,11))	

user.dreams.create!(title: "A Dream",
		body: "Once a dream did weave a shade
O'er my angel-guarded bed,
That an emmet lost its way
Where on grass methought I lay.

Troubled, wildered, and forlorn,
Dark, benighted, travel-worn,
Over many a tangle spray,
All heart-broke, I heard her say:

'Oh my children! do they cry,
Do they hear their father sigh? 
Now they look abroad to see,
Now return and weep for me.'

Pitying, I dropped a tear:
But I saw a glow-worm near,
Who replied, 'What wailing wight
Calls the watchman of the night? 

'I am set to light the ground,
While the beetle goes his round:
Follow now the beetle's hum; 
Little wanderer, hie thee home! ' . 

#human @william",
dreamed_on: Date.new(2012,2,11))	

user.dreams.create!(title: "A Little Boy Lost",
		body: "Nought loves another as itself,
Nor venerates another so,
Nor is it possible to thought
A greater than itself to know.

'And, father, how can I love you 
Or any of my brothers more? 
I love you like the little bird
That picks up crumbs around the door.'

The Priest sat by and heard the child; 
In trembling zeal he seized his hair,
He led him by his little coat,
And all admired the priestly care. 

And standing on the altar high,
'Lo, what a fiend is here! said he:
'One who sets reason up for judge
Of our most holy mystery.'

The weeping child could not be heard,
The weeping parents wept in vain:
They stripped him to his little shirt,
And bound him in an iron chain,

And burned him in a holy place
Where many had been burned before; 
The weeping parents wept in vain.
Are such thing done on Albion's shore?. 

#human @william",
impression: 2,
dreamed_on: Date.new(2012,2,11))	

user.dreams.create!(title: "The Garden of Love",
		body: "I went to the Garden of Love,
And saw what I never had seen; 
A Chapel was built in the midst,
Where I used to play on the green.

And the gates of this Chapel were shut
And 'Thou shalt not,' writ over the door; 
So I turned to the Garden of Love
That so many sweet flowers bore.

And I saw it was filled with graves,
And tombstones where flowers should be; 
And priests in black gowns were walking their rounds,
And binding with briars my joys and desires.  

#human @william",
impression: 3,
dreamed_on: Date.new(2012,2,11))	

user.dreams.create!(title: "A Little Girl Lost",
		body: "Children of the future age,
Reading this indignant page,
Know that in a former time
Love, sweet love, was thought a crime.

In the age of gold,
Free from winter's cold,
Youth and maiden bright,
To the holy light,
Naked in the sunny beams delight.

Once a youthful pair,
Filled with softest care,
Met in garden bright
Where the holy light
Had just removed the curtains of the night.

Then, in rising day,
On the grass they play;
Parents were afar,
Strangers came not near,
And the maiden soon forgot her fear.

Tired with kisses sweet,
They agree to meet
When the silent sleep
Waves o'er heaven's deep,
And the weary tired wanderers weep.

To her father white
Came the maiden bright;
But his loving look,
Like the holy book
All her tender limbs with terror shook.

'Ona, pale and weak,
To thy father speak!
Oh the trembling fear!
Oh the dismal care
That shakes the blossoms of my hoary hair!' 

#human @william",
dreamed_on: Date.new(2012,2,11))	

user.dreams.create!(title: "And Did Those Feet In Ancient Time",
		body: "And did those feet in ancient time
Walk upon England's mountains green?
And was the holy Lamb of God
On England's pleasant pastures seen?

And did the Countenance Divine
Shine forth upon our clouded hills?
And was Jerusalem builded here
Among these dark satanic mills?

Bring me my bow of burning gold!
Bring me my arrows of desire!
Bring me my spear! O clouds, unfold!
Bring me my chariot of fire!

I will not cease from mental fight,
Nor shall my sword sleep in my hand,
Till we have built Jerusalem
In England's green and pleasant land.  

#human @william",
dreamed_on: Date.new(2012,2,11))	

user.dreams.create!(title: "Three Things to Remember",
		body: "A Robin Redbreast in a cage,
Puts all Heaven in a rage. 

A skylark wounded on the wing
Doth make a cherub cease to sing. 

He who shall hurt the little wren
Shall never be beloved by men. 

#human @william",
impression: 2,
dreamed_on: Date.new(2012,2,11))	

user.dreams.create!(title: "Broken Love",
		body: "MY Spectre around me night and day 
Like a wild beast guards my way; 
My Emanation far within 
Weeps incessantly for my sin. 

‘A fathomless and boundless deep, 
There we wander, there we weep; 
On the hungry craving wind 
My Spectre follows thee behind. 

‘He scents thy footsteps in the snow 
Wheresoever thou dost go, 
Thro’ the wintry hail and rain. 
When wilt thou return again? 

’Dost thou not in pride and scorn 
Fill with tempests all my morn, 
And with jealousies and fears 
Fill my pleasant nights with tears? 

‘Seven of my sweet loves thy knife 
Has bereavèd of their life. 
Their marble tombs I built with tears, 
And with cold and shuddering fears. 

‘Seven more loves weep night and day 
Round the tombs where my loves lay, 
And seven more loves attend each night 
Around my couch with torches bright. 

‘And seven more loves in my bed 
Crown with wine my mournful head, 
Pitying and forgiving all 
Thy transgressions great and small. 

‘When wilt thou return and view 
My loves, and them to life renew? 
When wilt thou return and live? 
When wilt thou pity as I forgive?’ 

‘O’er my sins thou sit and moan: 
Hast thou no sins of thy own? 
O’er my sins thou sit and weep, 
And lull thy own sins fast asleep. 

‘What transgressions I commit 
Are for thy transgressions fit. 
They thy harlots, thou their slave; 
And my bed becomes their grave. 

‘Never, never, I return: 
Still for victory I burn. 
Living, thee alone I’ll have; 
And when dead I’ll be thy grave. 

‘Thro’ the Heaven and Earth and Hell 
Thou shalt never, quell: 
I will fly and thou pursue: 
Night and morn the flight renew.’ 

‘Poor, pale, pitiable form 
That I follow in a storm; 
Iron tears and groans of lead 
Bind around my aching head. 

‘Till I turn from Female love 
And root up the Infernal Grove, 
I shall never worthy be 
To step into Eternity. 

‘And, to end thy cruel mocks, 
Annihilate thee on the rocks, 
And another form create 
To be subservient to my fate. 

‘Let us agree to give up love, 
And root up the Infernal Grove; 
Then shall we return and see 
The worlds of happy Eternity. 

‘And throughout all Eternity 
I forgive you, you forgive me. 
As our dear Redeemer said: 
“This the Wine, and this the Bread.”’

#human @william",
dreamed_on: Date.new(2012,2,11))	

user.dreams.create!(title: "Ah Sunflower",
		body: "Ah Sunflower, weary of time,
Who countest the steps of the sun; 
Seeking after that sweet golden clime
Where the traveller's journey is done; 

Where the Youth pined away with desire,
And the pale virgin shrouded in snow,
Arise from their graves, and aspire
Where my Sunflower wishes to go! 

#human @william",
impression: 3,
dreamed_on: Date.new(2012,2,11))		

user.dreams.create!(title: "London",
		body: "I wandered through each chartered street,
Near where the chartered Thames does flow,
A mark in every face I meet,
Marks of weakness, marks of woe.

In every cry of every man,
In every infant's cry of fear,
In every voice, in every ban,
The mind-forged manacles I hear:

How the chimney-sweeper's cry
Every blackening church appals,
And the hapless soldier's sigh
Runs in blood down palace-walls.

But most, through midnight streets I hear
How the youthful harlot's curse
Blasts the new-born infant's tear,
And blights with plagues the marriage-hearse. 

#human @william",
dreamed_on: Date.new(2012,2,11))			

end