platform:ios,’7.0’

# ruby语法
# target数组 如果有新的target直接加入该数组
targetsArray = ['SGLive']
# 循环
targetsArray.each do |t|
    target t do
        pod 'AFNetworking'
    end
end

#target 'SuanGuo' do
#
# pod 'AFNetworking'
#end

if defined? installer_representation.project
    installer_representation.project.targets.each do |target|
         target.build_configurations.each do |config|
                config.build_settings[‘ONLY_ACTIVE_ARCH’] = ‘NO’
         end
	end
end

if defined? installer_representation.pods_project
    installer_representation.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
                config.build_settings[‘ONLY_ACTIVE_ARCH’] = ‘NO’
         end
	end
end
