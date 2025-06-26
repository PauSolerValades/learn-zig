# Perque tenir allocators i no malloc?

Fonts: https://www.youtube.com/watch?v=vHWiDx_l4V0, https://zig.guide/standard-library/allocators/

## Idea resum

Bàsicament mentre em fa mandra escriure això bé.

La memòria no és màgia, sinó que malloc crida el sistema operatiu. Aquest, usa la virtualització de la memòria per donar una equivalència entre hardware RAM i les adresses virtuals, i això s'acostuma a fer amb pàgines de memòria, ja que agafar-la a trossos seria massa ineficient. Per tant, zig "replica" això i té el `page_allocator`, que retorna una pàgina de memòria de la RAM. Això és overkill si tenim en compte que moltes vegades no es vol tanta memòria per només petites coses, i per això zig posa a disposició l'ArenaAllocator, que permet demanar més memòria sense replicar la crida al sistema operatiu (és a dir, ArenaAllocator rep la pàgina de `page_allocator`, i ell la gestiona per tu) replicant el concepte d'Arena Allocation en C o C++. L'altra filosofia és usar directament la memòria, i per tant existeix un GeneralPuroposeAllocator, que et permet demanar memòria especificant exactametn quanta, i és en teoria més ràpid que el `page_allocator`.

Resum bàsic d'allocadors:
1. `page_allocator`: més ineficient però el més senzill a nivell de hardware.
2. `ArenaAllocator`: Gestiona la memòria del page allocator, simulant el concepte d'Arena allocation, que obviament rep per paràmetre.
3. `GeneralPuroposeAllocator`: Allocador general, és millor que el page però no sé perque.
