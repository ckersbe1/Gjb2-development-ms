function soundData = loadSoundFile(working_dir)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    sound_file = dir(working_dir + "\sound_file*");
    sound_fp = sound_file.folder + "\" + sound_file.name;
    soundData = load(sound_fp);
end