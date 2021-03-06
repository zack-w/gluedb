puts "Loading: Users"
User.collection.drop

def add_a_user(login, e_pass)
  new_user = User.new({ email: login})
  new_user.encrypted_password = e_pass
  new_user.approved = true
  new_user.save!(validate: false)
end

  add_a_user(
    "trey.evans@dc.gov",
    "$2a$10$6reqq1aLphmF9i9Rlf1s5.Qq4x5abQf/gmKzgWa9njJNZk.LyEC7e"
  )
  add_a_user(
    "dan.thomas@dc.gov",
    "$2a$10$DzT.gqAI1..R8VCxfcn20.bTDIH7H4OO4b.X5IHdkxNbQw1qrXgoS"
  )
  add_a_user(
    "saadi.mirza@dc.gov",
    "$2a$10$JNZMpgDisJkWzCV1AhSzluo3PRFDERbNjE9r1EN6f/43ynGoL3ILi"
  )
  add_a_user(
    "holly.whelan@dc.gov",
    "$2a$10$UNcjMQazZstmx89kBubqgeG81J827UBk7UMs7ENSVAycqG4JW/5tS"
  )
  add_a_user(
    "isabella.leung@dc.gov",
    "$2a$10$IOUiQGrjyqFhwnAmXh0ewe8WZtRdib8l6w7oj17byxpDmmvbmCRZK"
  )
  add_a_user(
    "kenneth.taylor2@dc.gov",
    "$2a$10$nvvRSiLlwhBa0Ucse3mN/OSi8CjGgLzQhWLJASLuJyHP9GekH16wu"
  )
  add_a_user(
    "sarah.bagge@dc.gov",
    "$2a$10$KYCJ8PQDNcFBWlUacOBAHO7KRGFYuFe5JbfCzyJqLuP1vFlMqZ7om"
  )
  add_a_user(
    "brendan.rose2@dc.gov",
    "$2a$10$UIBsEkb5wigv1FG0.5QXh.p6CTCv5DOsGLdjqb83TliICK.liA52a"
  )
  add_a_user(
    "hannah.turner@dc.gov",
    "$2a$10$.S/gWw4GudPyNNkAxEiwXOQET8OCPA8fgEZRw6knrrfqWVekjpxGO"
  )
  add_a_user(
    "azizza.brown2@dc.gov",
    "$2a$10$5GGIDfa3vkPEyhpZz1r7juyvk/UUIO5sCNzwFHznVjb8URbN1kJOO"
  )
  add_a_user(
    "akash.dedhia@dc.gov",
    "$2a$10$1YmfnyGhxjBlLzfgG3NZBOCwDzaJjHa.8bWtbbvx6XaxINSxirwl."
  )
  add_a_user(
    "jack.pond@dc.gov",
    "$2a$10$.2pX3894vQ7hE3pw/tugTO/BTobp5P7VvYW29aa7HnTa/HAwkyH1."
  )
  add_a_user(
    "dan.northrup3@dc.gov",
    "$2a$10$EBN.uif0F0H3PrCKyDkNKOiiG0shBCIRuvzZpYV9P/fkQcRMkOk5e"
  )
  add_a_user(
    "cherie.smith@dc.gov",
    "$2a$10$vyCTfaLcCf/2S1b5CHJ67.MqYlG0BJQkhFiXjLsSDiW36q1ffUMou"
  )
  add_a_user(
    "alison.nelson@dc.gov",
    "$2a$10$zsRK2UDsx5ReY2tgDaaKTu9mBQzKmQhULSu1P/u5EPUQTxPRZMhXC"
  )
  add_a_user(
    "taryn.pope@dc.gov",
    "$2a$10$Y8eRlyGDCvpih02B7mzeT.a8ZSCj8OzAJRmBMUIv9d9lYWGYlecl2"
  )
  add_a_user(
    "khalid.mushtaq@dc.gov",
    "$2a$10$BQoj/Y96l8b7YaKovhkXd.oG8dLLpl454I6YJGBPk9RHmhs0jAeQy"
  )
  add_a_user(
    "alexander.alonso@dc.gov",
    "$2a$10$IKrH2.CT2DrpdjBlQsLg.Omvo9B6wiD8a7WI4an5k7uLwn6SUaztC"
  )
  add_a_user(
    "zoheb.nensey@dc.gov",
    "$2a$10$8FttkUM0jqvCjvaDgVXZf.XQF9/GBPwVB1xrEg8FdKpPtUWOSHTge"
  )
  add_a_user(
    "giselle.sorial@dc.gov",
    "$2a$10$UIOkG9fjPjFQhF8yR2OIOuN.rNdE7cD2u..85QPA0In7rSZPDnET6"
  )
  add_a_user(
    "stephen.haines@dc.gov",
    "$2a$10$XFH.54dXeU2wVwI2B4UOwuMCdFgRq5X6GQmJDUda3MwHePIBdCv.6"
  )
  add_a_user(
    "shelvia.armstrong@dc.gov",
    "$2a$10$jZ54u14m5usi/nKCgIxCa.wH7fxUQyqvq/puxf4GsD3WDb9Ilwcpa"
  )
  add_a_user(
    "john.kisor@dc.gov",
    "$2a$10$wvthMeSh5DfB3IUCA/PEfuq322hXnBxI2eiEUEUoktidN9B5kpU6q"
  )
  add_a_user(
    "micah.kidd@dc.gov",
    "$2a$10$CGPndVtDB9HlEuog3o9m3uhOTHpAR0eRf2Hq84xwIIhqqDYoG0IRS"
  )
  add_a_user(
    "candice.hammonds@dc.gov",
    "$2a$10$HjM8G3VcDLEBUlRlDCsGQOuGwtZuzRr/fEBiPOejsBokX2B4OiTTu"
  )
  add_a_user(
    "selamawit.teka@dc.gov",
    "$2a$10$Fm07ib6e7GM0VrmNQaq6UuwsewwgfD7TIV79btkjEnIgDVTCHwrDO"
  )
  add_a_user(
    "reza.beheshti@dc.gov",
    "$2a$10$YLyruc3CYpzqjLvOvjJhHuX2/7FYaA50y7yNl4C1uqEM3UsDquu2C"
  )
  add_a_user(
    "heather.parker@dc.gov",
    "$2a$10$w1n6u5XErDHiblHZCi7wqOIfVnD3Q5rVqRdvvsy26roVUmp0BwwE."
  )
  add_a_user(
    "camille.gray@dc.gov",
    "$2a$10$9gR/KrlVqNWY1tJugHLhiubWj2uYfBbm699o3PY/BK89.fmuAHduq"
  )
  add_a_user(
    "velvia.worrell@dc.gov",
    "$2a$10$SXJBADmcnzSRLPTrcHLhqeD7yCaMWedunykQ8lodxPo4exKJfzTme"
  )
