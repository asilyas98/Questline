import Foundation

struct Quote { let text: String; let author: String }

/// 365 quotes — one per day of the year (day 366 wraps to #1).
enum Quotes {
    static let all: [Quote] = raw.split(separator: "\n").map { line in
        let parts = line.split(separator: "|", maxSplits: 1).map(String.init)
        return Quote(text: parts[0], author: parts.count > 1 ? parts[1] : "Unknown")
    }

    static func forDate(_ date: Date = Date()) -> Quote {
        all[(Day.dayOfYear(date) - 1) % all.count]
    }

    private static let raw = """
We are what we repeatedly do. Excellence, then, is not an act, but a habit.|Will Durant
The journey of a thousand miles begins with one step.|Lao Tzu
It does not matter how slowly you go as long as you do not stop.|Confucius
Well done is better than well said.|Benjamin Franklin
Energy and persistence conquer all things.|Benjamin Franklin
Lost time is never found again.|Benjamin Franklin
Whether you think you can, or you think you can't — you're right.|Henry Ford
The best time to plant a tree was 20 years ago. The second best time is now.|Chinese proverb
Fall seven times, stand up eight.|Japanese proverb
Discipline is the bridge between goals and accomplishment.|Jim Rohn
Motivation is what gets you started. Habit is what keeps you going.|Jim Rohn
You must either modify your dreams or magnify your skills.|Jim Rohn
Success is the sum of small efforts, repeated day in and day out.|Robert Collier
I am not afraid of storms, for I am learning how to sail my ship.|Louisa May Alcott
It always seems impossible until it's done.|Nelson Mandela
What we fear doing most is usually what we most need to do.|Tim Ferriss
You do not rise to the level of your goals. You fall to the level of your systems.|James Clear
Every action you take is a vote for the type of person you wish to become.|James Clear
Habits are the compound interest of self-improvement.|James Clear
The man who moves a mountain begins by carrying away small stones.|Confucius
Do what you can, with what you have, where you are.|Theodore Roosevelt
Believe you can and you're halfway there.|Theodore Roosevelt
Nothing in the world is worth having or worth doing unless it means effort.|Theodore Roosevelt
Comparison is the thief of joy.|Theodore Roosevelt
In the middle of difficulty lies opportunity.|Albert Einstein
Life is like riding a bicycle. To keep your balance you must keep moving.|Albert Einstein
Strive not to be a success, but rather to be of value.|Albert Einstein
A person who never made a mistake never tried anything new.|Albert Einstein
The only way to do great work is to love what you do.|Steve Jobs
If you are going through hell, keep going.|Winston Churchill
You miss 100% of the shots you don't take.|Wayne Gretzky
I've failed over and over and over again in my life. And that is why I succeed.|Michael Jordan
Talent wins games, but teamwork and intelligence win championships.|Michael Jordan
Hard work beats talent when talent doesn't work hard.|Tim Notke
Don't count the days. Make the days count.|Muhammad Ali
The man who has no imagination has no wings.|Muhammad Ali
He who has a why to live can bear almost any how.|Friedrich Nietzsche
First say to yourself what you would be; and then do what you have to do.|Epictetus
No man is free who is not master of himself.|Epictetus
Waste no more time arguing what a good man should be. Be one.|Marcus Aurelius
The impediment to action advances action. What stands in the way becomes the way.|Marcus Aurelius
You have power over your mind — not outside events. Realize this, and you will find strength.|Marcus Aurelius
Luck is what happens when preparation meets opportunity.|Seneca
While we are postponing, life speeds by.|Seneca
It is not that we have a short time to live, but that we waste a lot of it.|Seneca
Difficulties strengthen the mind, as labor does the body.|Seneca
He who conquers himself is the mightiest warrior.|Confucius
Knowing yourself is the beginning of all wisdom.|Aristotle
Well begun is half done.|Aristotle
The beginning is the most important part of the work.|Plato
The two most powerful warriors are patience and time.|Leo Tolstoy
Everyone thinks of changing the world, but no one thinks of changing himself.|Leo Tolstoy
Yesterday I was clever, so I wanted to change the world. Today I am wise, so I am changing myself.|Rumi
What you seek is seeking you.|Rumi
Raise your words, not your voice. It is rain that grows flowers, not thunder.|Rumi
Act as if what you do makes a difference. It does.|William James
Action is the foundational key to all success.|Pablo Picasso
Inspiration exists, but it has to find you working.|Pablo Picasso
I am always doing that which I cannot do, in order that I may learn how to do it.|Pablo Picasso
Perseverance is not a long race; it is many short races one after the other.|Walter Elliot
Start where you are. Use what you have. Do what you can.|Arthur Ashe
Small deeds done are better than great deeds planned.|Peter Marshall
Strength does not come from physical capacity. It comes from an indomitable will.|Mahatma Gandhi
Live as if you were to die tomorrow. Learn as if you were to live forever.|Mahatma Gandhi
In a gentle way, you can shake the world.|Mahatma Gandhi
Education is the most powerful weapon which you can use to change the world.|Nelson Mandela
I learned that courage was not the absence of fear, but the triumph over it.|Nelson Mandela
Faith is taking the first step even when you don't see the whole staircase.|Martin Luther King Jr.
If you can't fly then run, if you can't run then walk, if you can't walk then crawl, but whatever you do you have to keep moving forward.|Martin Luther King Jr.
The time is always right to do what is right.|Martin Luther King Jr.
Do one thing every day that scares you.|Mary Schmich
You gain strength, courage, and confidence by every experience in which you really stop to look fear in the face.|Eleanor Roosevelt
Nothing will work unless you do.|Maya Angelou
You may encounter many defeats, but you must not be defeated.|Maya Angelou
If you don't like something, change it. If you can't change it, change your attitude.|Maya Angelou
You can't use up creativity. The more you use, the more you have.|Maya Angelou
The best way out is always through.|Robert Frost
Go confidently in the direction of your dreams.|Henry David Thoreau
Our life is frittered away by detail. Simplify, simplify.|Henry David Thoreau
What you do speaks so loudly that I cannot hear what you say.|Ralph Waldo Emerson
Genius is one percent inspiration and ninety-nine percent perspiration.|Thomas Edison
I have not failed. I've just found 10,000 ways that won't work.|Thomas Edison
Our greatest weakness lies in giving up. The most certain way to succeed is always to try just one more time.|Thomas Edison
Tough times never last, but tough people do.|Robert H. Schuller
Either you run the day or the day runs you.|Jim Rohn
Don't wish it were easier. Wish you were better.|Jim Rohn
Your life does not get better by chance, it gets better by change.|Jim Rohn
The successful warrior is the average man, with laser-like focus.|Bruce Lee
Absorb what is useful, discard what is useless, and add what is specifically your own.|Bruce Lee
I fear not the man who has practiced 10,000 kicks once, but the man who has practiced one kick 10,000 times.|Bruce Lee
Knowing is not enough; we must apply. Willing is not enough; we must do.|Johann Wolfgang von Goethe
Champions keep playing until they get it right.|Billie Jean King
It's not whether you get knocked down; it's whether you get up.|Vince Lombardi
Be so good they can't ignore you.|Steve Martin
Done is better than perfect.|Sheryl Sandberg
What would you do if you weren't afraid?|Sheryl Sandberg
Dream big. Start small. Act now.|Robin Sharma
Change is hard at first, messy in the middle and gorgeous at the end.|Robin Sharma
The secret of change is to focus all of your energy not on fighting the old, but on building the new.|Dan Millman
People often say that motivation doesn't last. Well, neither does bathing — that's why we recommend it daily.|Zig Ziglar
You don't have to be great to start, but you have to start to be great.|Zig Ziglar
What you get by achieving your goals is not as important as what you become by achieving your goals.|Zig Ziglar
Great things are done by a series of small things brought together.|Vincent van Gogh
If you hear a voice within you say you cannot paint, then by all means paint and that voice will be silenced.|Vincent van Gogh
Little by little, one travels far.|Spanish proverb
The way to get started is to quit talking and begin doing.|Walt Disney
All our dreams can come true, if we have the courage to pursue them.|Walt Disney
Nothing is impossible. The word itself says "I'm possible!"|Audrey Hepburn
Courage doesn't always roar.|Mary Anne Radmacher
The harder the conflict, the more glorious the triumph.|Thomas Paine
If there is no struggle, there is no progress.|Frederick Douglass
Ever tried. Ever failed. No matter. Try again. Fail again. Fail better.|Samuel Beckett
A ship in harbor is safe, but that is not what ships are built for.|John A. Shedd
It's not the load that breaks you down, it's the way you carry it.|Lou Holtz
Never let the fear of striking out keep you from playing the game.|Babe Ruth
Do the hard jobs first. The easy jobs will take care of themselves.|Dale Carnegie
Inaction breeds doubt and fear. Action breeds confidence and courage.|Dale Carnegie
Courage is resistance to fear, mastery of fear — not absence of fear.|Mark Twain
Focus on being productive instead of busy.|Tim Ferriss
The more I practice, the luckier I get.|Gary Player
There are no shortcuts to any place worth going.|Beverly Sills
Too many of us are not living our dreams because we are living our fears.|Les Brown
Patience is the companion of wisdom.|Saint Augustine
Amateurs sit and wait for inspiration, the rest of us just get up and go to work.|Stephen King
The scariest moment is always just before you start.|Stephen King
Make each day your masterpiece.|John Wooden
Don't let what you cannot do interfere with what you can do.|John Wooden
Be quick, but don't hurry.|John Wooden
It's the little details that are vital. Little things make big things happen.|John Wooden
Little strokes fell great oaks.|Benjamin Franklin
An investment in knowledge pays the best interest.|Benjamin Franklin
Never put off till tomorrow what you can do today.|Thomas Jefferson
Determine never to be idle.|Thomas Jefferson
Slow and steady wins the race.|Aesop
No act of kindness, no matter how small, is ever wasted.|Aesop
A smooth sea never made a skilled sailor.|English proverb
Rome wasn't built in a day.|English proverb
Where there's a will, there's a way.|English proverb
Vision without action is a daydream. Action without vision is a nightmare.|Japanese proverb
Even monkeys fall from trees.|Japanese proverb
One kind word can warm three winter months.|Japanese proverb
The bamboo that bends is stronger than the oak that resists.|Japanese proverb
Teachers open the door, but you must enter by yourself.|Chinese proverb
Do not fear going forward slowly; fear only standing still.|Chinese proverb
When the winds of change blow, some build walls, others build windmills.|Chinese proverb
He who asks a question is a fool for five minutes; he who does not remains a fool forever.|Chinese proverb
If you want to go fast, go alone. If you want to go far, go together.|African proverb
Patience is a tree whose root is bitter, but its fruit is very sweet.|Persian proverb
Trust in God, but tie your camel.|Arabic proverb
He who has health has hope, and he who has hope has everything.|Arabic proverb
Today's XP is earned in minutes, not moods.|Questline
You don't need a new life. You need a better next hour.|Questline
Show up badly before you show up perfectly.|Questline
The streak doesn't care how you feel. It cares that you came.|Questline
Small wins, stacked daily, become a different person.|Questline
Be the main character who actually does the side quests.|Questline
Level 1 is not a failure. It's the starting line.|Questline
Your future self is the reward. Today is the grind.|Questline
One honest rep beats a hundred planned ones.|Questline
Don't break the chain — and if you do, start a new one tonight.|Questline
Hard things get easier the moment you start them.|Questline
Progress hides in the boring days.|Questline
You can't skip levels, but you can stop quitting them.|Questline
Do the next right thing. Then the next one.|Questline
Every boss fight looks impossible from the first room.|Questline
Comfort is the one enemy that never attacks you directly.|Questline
Your habits are casting votes. Make today's count.|Questline
Effort is the one stat no one can take from you.|Questline
A missed day is a dip, not a defeat.|Questline
Write the proof. Future you will need the reminder.|Questline
Earn the reward, then enjoy it without guilt.|Questline
Two minutes of starting beats two hours of thinking.|Questline
Consistency is just courage, repeated.|Questline
Discipline today is freedom tomorrow.|Questline
Be patient with the process and ruthless with excuses.|Questline
You are allowed to be a beginner. You're not allowed to stay stuck.|Questline
Grind quietly. Let the stats speak.|Questline
Most quests are won in the middle, when nobody's watching.|Questline
Rest is part of training. Quitting is not.|Questline
Your energy follows your actions, not the other way around.|Questline
Make it easy to start and hard to skip.|Questline
When it feels slow, remember: slow still counts.|Questline
You become what you practice most.|Questline
Choose the hard thing that makes life easier.|Questline
Be kind to yourself and firm with yourself.|Questline
Every expert was once a level 1 character.|Questline
Today's small step is tomorrow's milestone.|Questline
Momentum is built, not found.|Questline
Win the morning, and the day follows.|Questline
The best motivation is a finished task.|Questline
Doubt fades when the checkmark appears.|Questline
Don't wait to feel ready. Ready is a feeling that comes after.|Questline
Character is built in the moments you almost quit.|Questline
Your goals are real, so your effort should be too.|Questline
A good day is one you're proud to log.|Questline
Small and consistent outruns big and occasional.|Questline
Life rewards those who keep showing up.|Questline
Clear one milestone. Just one.|Questline
Hard now, easy later. Easy now, hard later.|Questline
What you do today echoes in your stats tomorrow.|Questline
Bad days still count when you do the minimum.|Questline
You are one decision away from a different direction.|Questline
The quest is long, but you only have to walk today.|Questline
Strength grows where comfort ends.|Questline
Don't compare your level 3 to someone else's level 30.|Questline
Your effort is invisible until suddenly it isn't.|Questline
The work you avoid is usually the work that matters.|Questline
Make your bed, make your plan, make your move.|Questline
A wasted hour is XP left on the table.|Questline
Train your Body, feed your Mind, guard your Spirit, sharpen your Craft, honor your Bonds.|Questline
Give today a reason to be remembered.|Questline
Discomfort is the cost of the upgrade.|Questline
No one is coming to do it for you — and that's good news.|Questline
Plans are maps; action is the journey.|Questline
Finish what you start, even if it's ugly.|Questline
The tired version of you can still do something.|Questline
Protect your focus like it's your health bar.|Questline
Celebrate progress, not just perfection.|Questline
Be the hero of your own story by acting like one.|Questline
Gratitude turns what you have into enough.|Questline
Every day is a new save file.|Questline
Repetition is the mother of mastery.|Questline
Your phone can wait. Your goals have waited long enough.|Questline
Treat your time like gold — it's worth more.|Questline
Fear is often a sign you've found something worth doing.|Questline
The strongest people are built by the hardest seasons.|Questline
Courage is acting while scared.|Questline
Show up for the people who show up for you.|Questline
Ask for help. Even heroes travel with a party.|Questline
Kindness is a stat that levels up everyone around you.|Questline
Don't just plan the climb. Take the first step.|Questline
You can't control the outcome. You can control the reps.|Questline
One percent better every day adds up to a whole new you.|Questline
Turn "someday" into a date on the calendar.|Questline
Your best is enough, and it grows every time you give it.|Questline
Excuses don't earn XP.|Questline
Pick progress over perfection, every single day.|Questline
Quiet consistency beats loud intentions.|Questline
You've survived every hard day so far.|Questline
The goal isn't to be perfect. It's to be better than yesterday.|Questline
Start small enough that you can't say no.|Questline
Hard work compounds just like money.|Questline
Your attention is your most valuable resource. Spend it wisely.|Questline
Don't break your promises to yourself.|Questline
Self-respect is built by keeping small promises.|Questline
A habit missed once is a slip. Missed twice, it's a new habit. Never miss twice.|Questline
Let your actions answer your doubts.|Questline
Learn something today that future you will thank you for.|Questline
Sleep is a power-up. Use it.|Questline
Drink the water. Take the walk. Make the call.|Questline
Your environment is part of your build. Design it well.|Questline
Remove one distraction and watch your speed increase.|Questline
The secret level unlocks for those who keep playing.|Questline
You are not behind. You are on your own quest.|Questline
Sometimes the bravest thing is to begin again.|Questline
What gets measured gets improved.|Questline
Make the next 25 minutes count.|Questline
Do it for the person you're becoming.|Questline
Pressure makes diamonds. Patience polishes them.|Questline
Habits are boring until they make you extraordinary.|Questline
A little progress each day adds up to big results.|Questline
Be stubborn about your goals and flexible about your methods.|Questline
The grind is temporary. The growth is permanent.|Questline
Every hard choice is a deposit in your future.|Questline
It's okay to go slow. It's not okay to go nowhere.|Questline
You don't find time. You make it.|Questline
Silence the noise. Do the work.|Questline
Mistakes are XP in disguise.|Questline
Ordinary actions, done daily, create extraordinary lives.|Questline
There's no final level. Enjoy the game.|Questline
Build a life you don't need a vacation from.|Questline
Let today be the day you stop waiting.|Questline
Make it a habit and it stops being a fight.|Questline
Strong roots grow in silence.|Questline
Discipline is remembering what you really want.|Questline
The view gets better the higher you climb.|Questline
Life is full of side quests. Make them worth it.|Questline
Small hinges swing big doors.|Questline
Focus on the step, not the staircase.|Questline
You only lose the game when you stop playing.|Questline
Prove yourself right.|Questline
The best project you'll ever work on is you.|Questline
Count wins, not hours.|Questline
A clear goal turns wandering into a journey.|Questline
When you can't do it all, do the most important thing.|Questline
Energy is earned by moving.|Questline
Never quit on a bad day.|Questline
Your streak is a story. Keep writing it.|Questline
If it matters to you, schedule it.|Questline
Plant seeds today. Harvest later.|Questline
Commitment is doing it after the excitement fades.|Questline
Results love routines.|Questline
Make today's version of you hard to beat tomorrow.|Questline
Every boss has a weak point: you showing up again.|Questline
Fortune favors the consistent.|Questline
Work hard in silence. Let success make the noise.|Questline
Feelings are visitors. Let them come, but let your goals lead.|Questline
Today counts. Make it count.|Questline
Choose growth even when it's uncomfortable.|Questline
A strong finish starts with a stubborn start.|Questline
Don't let a slow week fool you. Seeds grow underground first.|Questline
You were made for more than scrolling.|Questline
The best reward is the person you become.|Questline
Fix your sleep, fix your mornings, fix your days.|Questline
Listen more than you speak today.|Questline
Forgive yesterday. Own today.|Questline
Ambition is the fuel. Discipline is the engine.|Questline
You're closer than you were yesterday.|Questline
Pain is temporary. Pride lasts.|Questline
Rise, grind, reflect, repeat.|Questline
Make the right thing the easy thing.|Questline
Calm minds make clear moves.|Questline
Let your effort be louder than your doubt.|Questline
One page, one rep, one step. That's how it's done.|Questline
You are writing your legend one day at a time.|Questline
Be proud of how far you've come, and hungry for how far you'll go.|Questline
The quest log is full. Pick one and start.|Questline
Hold on. The level-up is closer than it feels.|Questline
Stay the course. The stats don't lie.|Questline
Today is a great day to beat your best.|Questline
Do it tired. Do it scared. Just do it.|Questline
Your comfort zone is a nice place, but nothing grows there.|Questline
Build momentum before you need it.|Questline
The hardest rep is the first one out of bed.|Questline
Be the person your goals need you to be.|Questline
Wins are earned in private before they're seen in public.|Questline
Stop negotiating with yourself. Start.|Questline
A goal you write down is a goal you take seriously.|Questline
Effort today, evidence tomorrow.|Questline
Choose the habit, and the habit will shape you.|Questline
Turn the setback into a side quest.|Questline
Good things take time. Great things take consistency.|Questline
You don't have to see the whole map to take the next step.|Questline
The difference between who you are and who you want to be is what you do.|Questline
Get one percent braver today.|Questline
Make a plan, then make it happen.|Questline
Don't let perfect be the enemy of finished.|Questline
What you repeat, you become.|Questline
Every checkmark is a promise kept.|Questline
Small progress is still progress.|Questline
Your future is created by what you do today, not tomorrow.|Questline
Struggle is the training montage. Keep going.|Questline
Respect the process. It's building you.|Questline
Tiny habits, giant results.|Questline
When motivation runs out, discipline takes the next shift.|Questline
Be relentless about the little things.|Questline
Life gets easier when you stop making it harder.|Questline
Write your goal. Break it down. Begin.|Questline
You have more in the tank than you think.|Questline
Today's discomfort is tomorrow's strength.|Questline
Take care of your body. It carries every quest.|Questline
Feed your mind something good today.|Questline
A peaceful heart makes the hard road lighter.|Questline
Sharpen the skill that pays your future.|Questline
Call the person you've been meaning to call.|Questline
Keep the main thing the main thing.|Questline
Done today beats perfect someday.|Questline
Don't count the obstacles. Count the steps.|Questline
Your story isn't over. Turn the page.|Questline
Train like the goal is already yours.|Questline
The road to mastery is paved with repetitions.|Questline
Be patient. Big levels take big XP.|Questline
Every sunrise is a respawn.|Questline
Stay humble, stay hungry, stay consistent.|Questline
End the day with something to log.|Questline
"""
}
